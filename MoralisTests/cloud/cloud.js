Moralis.Cloud.define("cryptopunks", async (request) => {
    // access the DB
    // access blockchain
    // access APIs
    // any Logic

    /*const text = request.params.texto;
    const text2 = getText()
    return text + text2;*/

    const ID = request.params.id;
    const query = new Moralis.Query("PunkTransfers");
    query.equalTo("objectId", ID); // Search the ID sent by query
    const data = await query.find(); // Retrieve All Data

    return data
});

Moralis.Cloud.define("transaction-by-date", async (request) => {
    const Timestamp = {
        "__type": "Date",
        "iso": request.params.date
    }

    const query = new Moralis.Query("PunkTransfers");
    query.equalTo("block_timestamp", Timestamp); // Search the Date sent by query
    const data = await query.find(); // Retrieve All Data

    return data
});

Moralis.Cloud.define("transactions-by-date", async (request) => {
    const Timestamp = {
        "__type": "Date",
        "iso": request.params.date
    }

    const query = new Moralis.Query("PunkTransfers");
    query.lessThanOrEqualTo("block_timestamp", Timestamp); // Search all Dates less or equal to the Date sent by query
    const data = await query.find(); // Retrieve All Data
    const array = []

    for (let i = 0; i < data.length; ++i) {
        array[i] = data[i];
    }

    return array
});

