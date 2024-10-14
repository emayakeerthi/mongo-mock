const { MongoClient } = require("mongodb");
const { MongoMemoryServer } = require("mongodb-memory-server");
async function setupDatabase() {
    // Create an instance of MongoMemoryServer
    const mongod = await MongoMemoryServer.create({
        binary: {
            os: {
                os: 'linux',
                dist: 'debian',
                release: '10'
            },
            version: '6.0.18',
            downloadDir: '/tmp'
        },
    });
    console.log('mongod', typeof mongod)
    // Get the URI to connect to the in-memory database
    const uri = mongod.getUri();

    // Connect to the in-memory database
    const client = new MongoClient(uri);
    await client.connect();
  
    // Get a reference to the database
    const db = client.db('testdb');
  
    return { mongod, client, db };
  }
  
  async function closeDatabase(mongod, client) {
    // Close the MongoDB client connection
    await client.close();
  
    // Stop the in-memory MongoDB instance
    await mongod.stop();
  }

  function addAwaitToFunctions(snippet) {
    // Regex pattern to find function calls
    const functionCallPattern = /(\w+\.\w+\(.*?\))/g;

    // Replace function calls with 'await' keyword prepended
    return snippet.replace(functionCallPattern, (match) => `await ${match}`);
}

  
  // Example usage
  async function runExample() {
    const { mongod, client, db } = await setupDatabase();
  
    try {
      // Use the database
      const collection = db.collection('users');
      await collection.insertOne({ name: 'John Doe', email: 'john@example.com' });
      const user = await collection.findOne({ name: 'John Doe' }, { projection: {_id: 0}});
  
       let userSnippet = `
            const collection = db.collection('users');
            const result = collection.findOne({});
            console.log(result);
        `;
  
        // Automatically append await for function calls
        userSnippet = addAwaitToFunctions(userSnippet);
        console.log('Modified snippet:', userSnippet);
  
        // Parse and execute the user's code
        const result = await eval(`(async () => { ${userSnippet} })()`);
      
    } finally {
      // Always close the connection when done
      await closeDatabase(mongod, client);
    }
  }
  
  runExample().catch((err) => {
      console.log(err)
  });
