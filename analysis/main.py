import argparse
from neo4j import GraphDatabase
import numpy as np
import matplotlib.pyplot as plt


def clear_db(client):
    records, summary, keys = client.execute_query(
        'MATCH (n) DETACH DELETE n;'
    )


def sort_dict(result, threshold=0):
    vals = [
        val 
        for val in result.items()
        if val[1] >= threshold
    ]
    return sorted(vals, key=lambda x:x[1], reverse=True)


def plot_bars(stats, length):
    # set width of bars
    name = 'DFG_ ' + str(length)

    bar_width = 0.20

    plt.figure(figsize=(8, 3))
    plt.grid(visible = True, axis = 'y', color = 'gray', linestyle = '--', linewidth = 0.5, alpha = 0.7)
    plt.grid(visible = True, axis = 'y', which='minor', color='#999999', linestyle='-', alpha=0.2)

    chains = [
        pair[0]
        for pair in stats
    ]
    counts = [
        pair[1]
        for pair in stats
    ]

    bars_y = counts
    bars_x = np.arange(len(bars_y))
    plt.bar(bars_x, bars_y, width=bar_width, edgecolor='white', label=chains, log=False)

    plt.title(name)
    ylabel = 'Count Inst.'
    plt.ylabel(ylabel)
    plt.xticks([r for r in range(len(chains))], chains)
    for index, label in enumerate(plt.gca().xaxis.get_ticklabels()):
        y_position = label.get_position()[1]  # Get current y position
        if index % 2 != 0:  # For odd indices
            label.set_y(y_position - 0.06)  # Move down by a fraction; adjust as needed

    plt.tight_layout()

    plt.savefig('./out/' + name + '_most_chains.pdf')

def plot_nodes(client, threshold=1000):
    query = 'MATCH (n) RETURN n;'
    
    # Count the number of nodes in the database
    records, summary, keys = client.execute_query(
        query
    )

    # Get the result
    recs = [
        record['n']['name']
        for record in records
    ]
    recs_cout = {
        nodes: recs.count(nodes)
        for nodes in recs
    }
    print(recs_cout)

    sorted = sort_dict(recs_cout, threshold)
    plot_bars(sorted, 1)


def plot_duplicated_chains(client, length, ignore=['Const', 'phi'], threshold=100):
    if type(length) == int and length > 0:
        query = 'MATCH p0=(n0)'
        for i in range(1, length):
            query += f'-[r{i}:DFG]->(n{i})'

        if len(ignore) > 0:
            query += ' WHERE ('
            for name in ignore:
                for i in range(0, length):
                    query += f'(NOT n{i}.name = \'{name}\') AND '

            query += 'true)'

        query += ' RETURN p0;'
        
        # Count the number of nodes in the database
        print('INFO', length, 'query:', query)
        records, summary, keys = client.execute_query(
            query
        )

        # Get the result
        recs = [
            ' -> '.join([
                node['name']
                for node in list(dict.fromkeys([
                    node
                    for r in record['p0']
                    for node in r.nodes
            ]))])
            for record in records
        ]
        recs_cout = {
            nodes: recs.count(nodes)
            for nodes in recs
        }
        print(recs_cout)

        sorted = sort_dict(recs_cout, threshold)
        plot_bars(sorted, length)


def print_num_nodes(client):
    # Count the number of nodes in the database
    records, summary, keys = client.execute_query(
        'MATCH (n) RETURN count(n) AS num_of_nodes;'
    )

    # Get the result
    for record in records:
        print('Number of nodes:', record['num_of_nodes'])


def main(args):
    uri = 'bolt://' + args.host + ':' + str(args.port)
    auth = ('', '')

    with GraphDatabase.driver(uri, auth=auth) as client:
        client.verify_connectivity()
        if args.clear_db:
            clear_db(client)
        else:
            print_num_nodes(client)
            plot_nodes(client, 500)
            ignore = ['Const']
            plot_duplicated_chains(client, 2, ignore, 500)
            plot_duplicated_chains(client, 3, ignore, 300)
            plot_duplicated_chains(client, 4, ignore, 250)
            plot_duplicated_chains(client, 5, ignore, 250)
        

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Analyze the File.')
    parser.add_argument('--host', nargs='?', type=str, default='localhost', help='host of the memgraph (or Neo4j) DB (reachable over bolt)')
    parser.add_argument('--port', nargs='?', type=int, default=7687, help='port of the Memgraph DB')
    parser.add_argument('--clear-db', nargs='?', type=bool, default=False, help='Clear the DB')
    main(parser.parse_args())
