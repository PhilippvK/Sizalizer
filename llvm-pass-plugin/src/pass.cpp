#include "llvm/IR/CFG.h"
#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/CodeGen/MachineFunction.h"

#include <iostream>
#include <mgclient.h>

using namespace llvm;
using namespace std;

namespace
{

    struct CDFGPass : public PassInfoMixin<CDFGPass>
    {
        string get_bb_name(BasicBlock *bb)
        {
            string str;
            raw_string_ostream OS(str);
            bb->printAsOperand(OS, false);
            return OS.str();
        }

        template <typename LLVM_Type>
        string llvm_to_string(LLVM_Type *obj)
        {
            string str;
            raw_string_ostream OS(str);
            OS << *obj << "\n";
            return OS.str();
        }

        mg_session *connect_to_db(const char *host, uint16_t port)
        {
            mg_init();
            printf("mgclient version: %s\n", mg_client_version());

            mg_session_params *params = mg_session_params_make();
            if (!params)
            {
                fprintf(stderr, "failed to allocate session parameters\n");
                exit(1);
            }
            mg_session_params_set_host(params, host);
            mg_session_params_set_port(params, port);
            mg_session_params_set_sslmode(params, MG_SSLMODE_DISABLE);

            mg_session *session = NULL;
            int status = mg_connect(params, &session);
            mg_session_params_destroy(params);
            if (status < 0)
            {
                printf("failed to connect to Memgraph: %s\n", mg_session_error(session));
                mg_session_destroy(session);
                exit(1);
            }
            return session;
        }

        void disconnect(mg_session *session)
        {
            mg_session_destroy(session);
            mg_finalize();
        }

        void exec_qeury(mg_session *session, const char *query)
        {
            if (mg_session_run(session, query, NULL, NULL, NULL, NULL) < 0)
            {
                outs() << "failed to execute query: " << mg_session_error(session) << "\n";
                mg_session_destroy(session);
                exit(1);
            }
            if (mg_session_pull(session, NULL))
            {
                outs() << "failed to pull results of the query: " << mg_session_error(session) << "\n";
                mg_session_destroy(session);
                exit(1);
            }

            int status = 0;
            mg_result *result;
            int rows = 0;
            while ((status = mg_session_fetch(session, &result)) == 1)
            {
                rows++;
            }

            if (status < 0)
            {
                outs() << "error occurred during query execution: " << mg_session_error(session) << "\n";
            }
            else
            {
                // printf("query executed successfuly and returned %d rows\n", rows);
            }
        }

        void connect_bbs(mg_session *session, BasicBlock *first_bb, BasicBlock *second_bb)
        {
            // MERGE: create if not exist else match
            string store_first = "MERGE (first_bb {name: '" + get_bb_name(first_bb) + "'})";
            string set_frist_code = " SET first_bb.code =  '" + llvm_to_string(first_bb) + "'";
            string store_second = " MERGE (second_bb {name: '" + get_bb_name(second_bb) + "'})";
            string set_second_code = " SET second_bb.code =  '" + llvm_to_string(second_bb) + "'";
            string rel = " MERGE (first_bb)-[:CFG]->(second_bb);";
            string qry = store_first + set_frist_code + store_second + set_second_code + rel;
            exec_qeury(session, qry.c_str());
        }

        void connect_insts(mg_session *session, string src_str, string dst_str)
        {
            // MERGE: create if not exist else match
            string store_src = "MERGE (src_inst {name: '" + src_str + "'})";
            string store_dst = " MERGE (dst_inst {name: '" + dst_str + "'})";
            string rel = " MERGE (src_inst)-[:DFG]->(dst_inst);";
            string qry = store_src + store_dst + rel;
            exec_qeury(session, qry.c_str());
        }

        PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM)
        {
            outs() << "Running CDFGPass\n";

            mg_session *session = connect_to_db("localhost", 7687);

            // Clear database
            auto del = "MATCH (n) DETACH DELETE n;";
            exec_qeury(session, del);

            // mapp the var to the last bb name
            map<string, string> var_to_bb;

            // Push CDFG to DB
            for (Function &F : M)
            {
                for (BasicBlock &bb : F)
                {
                    string bb_name = get_bb_name(&bb);
                    outs() << "Label: " << bb_name << "\n";

                    for (BasicBlock *suc_bb : successors(&bb))
                    {
                        connect_bbs(session, &bb, suc_bb);
                    }

                    for (Instruction &inst : bb)
                    {

                        string inst_str = llvm_to_string(&inst);
                        outs() << "  " << inst_str;

                        Instruction::op_iterator opEnd = inst.op_end();
                        for (Instruction::op_iterator opi = inst.op_begin(); opi != opEnd; opi++)
                        {

                            Value *op = opi->get();
                            Type *tp = op->getType();
                            if (!tp->isLabelTy())
                            {
                                string src_str = llvm_to_string(op);
                                // outs() << "    - " << src_str;

                                connect_insts(session, src_str, inst_str);
                            }
                        }
                    }
                }
            }

            disconnect(session);

            return PreservedAnalyses::all();
        }
    };

} // end anonymous namespace

PassPluginLibraryInfo
getPassPluginInfo()
{
    const auto callback = [](PassBuilder &PB)
    {
        PB.registerOptimizerLastEPCallback(
            [&](ModulePassManager &MPM, auto)
            {
                MPM.addPass(CDFGPass());
                return true;
            });
    };

    return {LLVM_PLUGIN_API_VERSION, "name", "0.0.1", callback};
};

extern "C" LLVM_ATTRIBUTE_WEAK PassPluginLibraryInfo llvmGetPassPluginInfo()
{
    return getPassPluginInfo();
}