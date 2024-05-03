import argparse
from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt
import string
import tikzplotlib


from helper import instruction_model, parse_utils, evaluator, modes, plotter

plt.rcParams.update({
    "text.usetex": True,
    "font.family": "sans-serif",
    "font.sans-serif": "Helvetica",
})

debug = False
plot_all = False


def parse_line(source_line):
    if source_line[0:1] == ' ' or source_line[0:1] == '1':
        source_line = source_line.strip()
        sl = source_line.replace('\t', ' ')
        while sl != source_line:
            source_line = sl
            sl = sl.replace('  ', ' ')
        elems = source_line.replace('  ', ' ').split(' ')
        elen = len(elems)
        if elen > 1:
            if debug:
                print(elems)

            address = elems[0]
            addr_len = len(address)
            assert len(address) > 0
            if address[addr_len-1] == ':':
                address = address[:(addr_len-1)]

                i = 1
                opcode = ''
                while len(elems[i]) == 2 and all(c in string.hexdigits for c in elems[i]) and i < 5:
                    opcode += elems[i]
                    i += 1
                
                mnemonic = elems[i]
                i += 1

                instruction = instruction_model.Instruction(address, opcode, mnemonic)

                if elen > i:
                    first_param = elems[i]
                    fp_len = len(first_param)
                    if fp_len == 0:
                        print(str(instruction))
                        print(first_param)
                    assert fp_len > 0
                    i += 1
                    if first_param[fp_len-1] == ',':
                        first_param = first_param[:(fp_len-1)]
                    instruction.regs.append(first_param)

                if elen > i:
                    second_param = elems[i]
                    i += 1
                    if second_param[-1] == ',':
                        second_param = second_param[:(len(second_param)-1)]
                    instruction.regs.append(second_param)

                if elen > i:
                    third_param = elems[i]
                    instruction.regs.append(third_param)
                
                if debug:
                    print(str(instruction))

                return instruction
            else:
                if debug:
                    print('ERROR: false assumed inst: ', source_line)
    else:
        if debug:
            print('INFO: not an inst: ', source_line)
    return None


def most_inst(instructions, mode=modes.Mode.ALL, search_key=modes.SearchKey.MNEMONIC, threshold=1): 
    result = {}
    for inst in instructions:
        is_comp = inst.get_size() == 2 and mode == modes.Mode.COMPRESSED
        is_full = inst.get_size() == 4 and mode == modes.Mode.FULL
        use_all = mode == modes.Mode.ALL
        if use_all or is_comp or is_full:
            keys = [inst.mnemonic]
            if search_key == modes.SearchKey.OPCODE:
                keys = [inst.opcode]
            if search_key == modes.SearchKey.REGISTER:
                keys = inst.regs
            for key in keys:
                if key in result:
                    result[key] += 1
                else:
                    result[key] = 1
    return evaluator.sort_dict(result, threshold)


def longest_chains(instructions, threshold=2):
    result = {}
    last_key = instructions[0].mnemonic
    chain_len = 1
    for inst in instructions[1:]:
        key = inst.mnemonic
        if last_key == key:
            chain_len += 1
        else:
            if chain_len >= threshold:
                if last_key in result:
                    if result[last_key] < chain_len:
                        result[last_key] = chain_len
                else:
                    result[last_key] = chain_len
            chain_len = 1
        last_key = key
    return evaluator.sort_dict(result, threshold)
    

def most_pairs(instructions, threshold=5, equal=True, connected=False):
    result = {}
    old_inst = instructions[0]
    for inst in instructions[1:]:
        old_mn = old_inst.mnemonic
        new_mn = inst.mnemonic
        is_equal = old_mn == new_mn or not equal
        is_connected = old_inst.get_dest() in inst.get_params() or not connected
        if is_equal and is_connected:
            key = old_mn
            if not equal:
                key = old_mn + '-' + new_mn
            if key in result:
                result[key] += 1
            else:
                result[key] = 1
        old_inst = inst
    return evaluator.sort_dict(result, threshold)


def get_improvement(stats, imp_map):
    imp = 0
    for stat in stats:
        imp += imp_map(stat[1])
    return imp


def plot_bars(stats, filename, path, mode=modes.Mode.ALL, search_key=modes.SearchKey.MNEMONIC):
    # set width of bars
    # usetex for latex plots
    name = filename.split('.')[0]

    bar_width = 0.20

    plt.figure(figsize=(8, 3))
    plt.grid(visible = True, axis = 'y', color = 'gray', linestyle = '--', linewidth = 0.5, alpha = 0.7)
    plt.grid(visible = True, axis = 'y', which='minor', color='#999999', linestyle='-', alpha=0.2)
    plt.rc('axes', unicode_minus=False)

    mnemonics = [
        pair[0]
        for pair in stats
    ]
    counts = [
        pair[1]
        for pair in stats
    ]

    bars_y = counts
    bars_x = np.arange(len(bars_y))
    plt.bar(bars_x, bars_y, width=bar_width, edgecolor='white', label=mnemonics, log=False)

    # plt.title(name)
    ylabel = search_key.value + ' Count ' +  mode.value + ' Inst.'
    # plt.ylabel(ylabel)
    plt.xticks([r for r in range(len(mnemonics))], mnemonics)
    for index, label in enumerate(plt.gca().xaxis.get_ticklabels()):
        y_position = label.get_position()[1]  # Get current y position
        if index % 2 != 0:  # For odd indices
            label.set_y(y_position - 0.06)  # Move down by a fraction; adjust as needed

    plt.tight_layout()
    # plt.legend().remove()

    fig_name = path + '/' + name + '_Static_' + search_key.value + '_' + mode.value
    plt.savefig(fig_name + '.pdf')
    # tikzplotlib.save(fig_name + '.tex')
    plt.close()

    
def get_byte_count(instructions):
    result = 0
    for inst in instructions:
        result += inst.get_size()
    return result


def main(args):
    path = str(Path(args.path).absolute())
    total = []
    for file in args.files:
        if debug:
            print('Base Path: ', path)
            print('File to analyze: ', file)


        instructions = []
        fqpn = '{}/{}'.format(str(path), str(file))
        instructions = parse_utils.parse_file(fqpn, parse_line, debug)
        if len(instructions) > 0:
            total += instructions
            total_byte_count = get_byte_count(instructions)
            inst_count = len(instructions)
            print(file, 'contains:', inst_count, 'insts, with', total_byte_count, 'bytes')
            
            if plot_all:
                for mode in modes.Mode:
                    stats = most_inst(instructions, mode, modes.SearchKey.MNEMONIC, 10)
                    plot_bars(stats, str(file), path, mode)
                stats = most_inst(instructions, modes.Mode.ALL, modes.SearchKey.OPCODE, 10)
                plot_bars(stats, str(file), path, modes.Mode.ALL, modes.SearchKey.OPCODE)

                stats = most_inst(instructions, modes.Mode.ALL, modes.SearchKey.REGISTER, 10)
                plot_bars(stats, str(file), path, modes.Mode.ALL, modes.SearchKey.REGISTER)
            
                chains = longest_chains(instructions, 10)
                plot_bars(chains, str(file), path, modes.Mode.ALL, modes.SearchKey.CHAIN)


            stats = most_inst(instructions, modes.Mode.FULL, modes.SearchKey.MNEMONIC, 10000000)
            # x contains count of 32 Bit (4 Byte) instructions
            # x*2 is the count of Bytes saved by a reduction to 16 bit inst
            improvement = get_improvement(stats, lambda x: x*2)
            print('  Improvement by replacing 32 with 16 Bit inst: ' + str(improvement) + ' Byte ==', round((1 - ((total_byte_count - improvement)/total_byte_count))*100), '%')

            if debug:
                pairs = most_pairs(instructions, 10, equal=True)
                for pair in pairs:
                    print(pair)
                print()

                pairs = most_pairs(instructions, 10, equal=False)
                for pair in pairs:
                    print(pair)
                print()

            pairs = most_pairs(instructions, 10, equal=False, connected=True)
            if plot_all:
                plot_bars(pairs, str(file), path, modes.Mode.ALL, modes.SearchKey.PAIR)



            pairs = most_pairs(instructions, 10, equal=False, connected=True)
            # x contains count of 16 or 32 Bit instructions pairs
            # x*6 is the count of Bytes saved by a reduction to 16 bit inst
            improvement = get_improvement(pairs, lambda x: x*6)
            # print('Max. improvement by replacing all 16 or 32 Bit instructions pairs with 16 Bit inst: ' + str(improvement) + ' Byte')
        else:
            print('ERROR: No instructions in', fqpn)
    if len(total) > 0:
        total_inst_count = len(total)
        total_byte_count = get_byte_count(total)
        print('Total:', total_inst_count, ' insts, with', total_byte_count, 'bytes')
        for mode in modes.Mode:
            stats = most_inst(total, mode, modes.SearchKey.MNEMONIC, 10)
            plot_bars(stats, '_Total', path, mode)

        stats = most_inst(total, modes.Mode.ALL, modes.SearchKey.OPCODE, 10)
        plot_bars(stats, '_Total', path, modes.Mode.ALL, modes.SearchKey.OPCODE)

        stats = most_inst(total, modes.Mode.ALL, modes.SearchKey.REGISTER, 10)
        plot_bars(stats, '_Total', path, modes.Mode.ALL, modes.SearchKey.REGISTER)
        
        chains = longest_chains(total, 10)
        plot_bars(chains, '_Total', path, modes.Mode.ALL, modes.SearchKey.CHAIN)


        stats = most_inst(total, modes.Mode.FULL, modes.SearchKey.MNEMONIC, 100000)
        # x contains count of 32 Bit (4 Byte) instructions
        # x*2 is the count of Bytes saved by a reduction to 16 bit inst
        improvement = get_improvement(stats, lambda x: x*2)
        print('  Total Improvement by replacing 32 with 16 Bit inst: ' + str(improvement) + ' Byte ==', round((1 - ((total_byte_count - improvement)/total_byte_count))*100), '%')

        if debug:
            pairs = most_pairs(total, 10, equal=True)
            for pair in pairs:
                print(pair)
            print()

            pairs = most_pairs(total, 10, equal=False)
            for pair in pairs:
                print(pair)
            print()

        pairs = most_pairs(total, 10, equal=False, connected=True)
        plot_bars(pairs, '_Total', path, modes.Mode.ALL, modes.SearchKey.PAIR)

        pairs = most_pairs(instructions, 1, equal=False, connected=True)
        # x contains count of 16 or 32 Bit instructions pairs
        # x*6 is the count of Bytes saved by a reduction to 16 bit inst
        improvement = get_improvement(pairs, lambda x: x*6)
    else:
        print('ERROR: In total no instructions')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Count the instructions in an assembly file.')
    parser.add_argument('files', metavar='F', type=str, nargs='+', help='files to analyze')
    parser.add_argument('--path', type=str, help='base path for the files')

    main(parser.parse_args())

