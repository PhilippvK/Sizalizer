#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/CodeGen/MachineFunction.h"

#include <iostream>
#include <mgclient.h>

using namespace llvm;

namespace
{

  struct MyPass : public PassInfoMixin<MyPass>
  {



    PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM)
    {
      outs() << "Running MyPass\n";

      // Open DB connection
      mg_init();
      printf("mgclient version: %s\n", mg_client_version());

      mg_session_params *params = mg_session_params_make();
      if (!params)
      {
        fprintf(stderr, "failed to allocate session parameters\n");
        exit(1);
      }
      mg_session_params_set_host(params, "localhost");
      mg_session_params_set_port(params, 7687);
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

      // Push CDFG to DB
      for (BasicBlock &bb : F)
      {
        outs() << bb.getName() << "\n";
        for (Instruction &inst : bb)
        {
          outs() << "inst: "
                 << inst
                 << "\n";
        }
      }

      // Close DB connection
      mg_session_destroy(session);
      mg_finalize();

      return PreservedAnalyses::all();
    }
  };

} // end anonymous namespace

PassPluginLibraryInfo getPassPluginInfo()
{
  const auto callback = [](PassBuilder &PB)
  {
    PB.registerPipelineEarlySimplificationEPCallback(
        [&](ModulePassManager &MPM, auto)
        {
          MPM.addPass(createModuleToFunctionPassAdaptor(MyPass()));
          return true;
        });
  };

  return {LLVM_PLUGIN_API_VERSION, "name", "0.0.1", callback};
};

extern "C" LLVM_ATTRIBUTE_WEAK PassPluginLibraryInfo llvmGetPassPluginInfo()
{
  return getPassPluginInfo();
}