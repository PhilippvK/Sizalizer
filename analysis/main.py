from neo4j import GraphDatabase
 
URI = "bolt://localhost:7687"
AUTH = ("", "")
 
with GraphDatabase.driver(URI, auth=AUTH) as client:
    client.verify_connectivity()
 
    # Count the number of nodes in the database
    records, summary, keys = client.execute_query(
        "MATCH (n) RETURN count(n) AS num_of_nodes;"
    )
 
    # Get the result
    for record in records:
        print('Number of nodes:', record["num_of_nodes"])