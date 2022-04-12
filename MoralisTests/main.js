// require("dotenv").config();

Moralis.initialize('UZSqeVQoEaE8T6ZJ2XKCdOcaVAPtDqpmLT39szsD');
Moralis.serverURL = 'https://pvvnotm4bih1.usemoralis.com:2053/server';

init = async () => {
    console.log("Ok")
    const hello = await Moralis.Cloud.run("cryptopunks?texto=esta-a-funcionar")
    console.log(hello)
}

init();
