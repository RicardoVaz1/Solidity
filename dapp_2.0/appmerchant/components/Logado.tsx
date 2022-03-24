import React, { useEffect, useState, useContext } from 'react'
import { client } from '../lib/sanityClient'
import { TransactionContext } from '../context/TransactionContext'
import Image from 'next/image'
import ethLogo from '../assets/ethCurrency.png'
import Main from '../components/Main'
import { useRouter } from 'next/router'
import snippetData from '../download/snippet.js'

const style = {
    wrapper: `max-h-screen h-min-screen w-screen text-white select-none flex flex-col`,
    wrapper2: `w-screen flex items-center justify-center mt-14`,
    content: `bg-[#191B1F] w-[40rem] rounded-2xl p-4`,
    content2: `bg-[#808080] w-[40rem] rounded-2xl p-4`,
    nav: `flex justify-center items-center`,
    navItemsContainer: `flex bg-[#191B1F] rounded-3xl`,
    navItem: `px-4 py-2 m-1 flex items-center text-lg font-semibold text-[0.9rem] cursor-pointer rounded-3xl`,
    activeNavItem: `bg-[#20242A] text-[#FFA500]`,
    fromAddress: `text-[#f48706] mx-2`,
    etherscanLink: `text-[#2172e5]`,
    invisible: `hidden`,
}



const Logado = () => {
    const [selectedNav, setSelectedNav] = useState('historic')
    const { isLoading, currentAccount, isLogout } = useContext(TransactionContext)
    const [transactionHistory, setTransactionHistory] = useState<any[]>([])
    const router = useRouter()

    useEffect(() => {
        ;(async () => {
        if (!isLoading && currentAccount) {
            const query = `
            *[_type=="users" && _id == "${currentAccount}"] {
                "transactionList": transactions[]->{amount, fromAddress, toAddress, timestamp, txHash}|order(timestamp desc)[0..4]
            }
            `

            const clientRes = await client.fetch(query)

            setTransactionHistory(clientRes[0].transactionList)
        }
        })()
    }, [isLoading, currentAccount])


    function downloadSnippet() {
        //console.log("Download")
        //router.push("/download/snippet.js")

        // var url = "data:text/js,HelloWorld!"
        var url = "../download/snippet.js"
        var mimetype = 'application/javascript';
        var filename = "snippet.js"

        //var data = `var text = "Hello world"\nconsole.log(text)`
        var data = snippetData
        //console.log(data)
        /*var data = snippetData

        fetch(data)
            .then(r => r.text())
            .then(text => {
                data = text
                console.log('text decoded:', text);
            });

        fetch(url)
            .then(function(t) {
                return t.blob().then((b)=>{
                    var a = document.createElement("a");
                    a.href = URL.createObjectURL(b);
                    a.setAttribute("download", filename);
                    a.click();
                }
                );
            });*/

        fetch(url)
            .then(function(t) {
                return t.blob().then((b)=>{
                    var a = window.document.createElement("a");
                    a.href = window.URL.createObjectURL(new Blob([data], {
                        encoding: "UTF-8",
                        type: mimetype + ";charset=UTF-8",
                    }));
                    a.download = filename;
                    a.click();
                });
            })
            .catch(error => {
                console.log(error)
            });
    }

    return (
        <div id="wrapper">
            <div className={ isLogout == true ? style.invisible : ""}>
                <div className={`${style.navItemsContainer}`} style={{width: "fit-content"}} onClick={() => downloadSnippet()}>
                    {/* <a href="../download/snippet.js" download="snippet.js"> */}
                        <span className={`${style.navItem}`}>
                            Download Snippet
                        </span>
                    {/* </a> */}
                </div>
            </div>
            <nav className={ isLogout == true ? style.invisible : ""}>
                <div className={style.navItemsContainer}>
                    <div
                        onClick={() => setSelectedNav('historic')}
                        className={`${style.navItem} ${
                        selectedNav === 'historic' && style.activeNavItem
                        }`}
                    >
                        Historic
                    </div>
                    <div
                        onClick={() => setSelectedNav('refunds')}
                        className={`${style.navItem} ${
                        selectedNav === 'refunds' && style.activeNavItem
                        }`}
                    >
                        Refunds
                    </div>
                </div>
            </nav>

            {selectedNav == 'historic' ? 
                (<div id='historic' className={ isLogout == true ? style.invisible : ""}>
                    <table>
                        <tr id="historic_header">
                            <td>Date</td>
                            <td>From</td>
                            <td>To</td>
                            <td>Value</td>
                            <td>Status</td>
                            <td>Hash</td>
                        </tr>
                        {/* <tr>
                            <td>14/03/2022</td>
                            <td>0x12...1238</td>
                            <td>0x23...4564</td>
                            <td>0.1 ETH</td>
                            <td>Complete</td>
                            <td>0x1212...</td>
                        </tr> */}

                        {transactionHistory && transactionHistory?.map((transaction, index) => (
                            <tr>
                                <td>
                                    {new Date(transaction.timestamp).toLocaleString('pt-PT', {
                                    // timeZone: 'GMT',
                                    // timeStyle: 'short',
                                    // dateStyle: 'short',
                                    // year: 'numeric',
                                    // month: 'long'
                                    })}
                                </td>

                                <td>
                                    <span className={ transaction.fromAddress == currentAccount ? style.fromAddress : ""}>
                                        {/* {transaction.fromAddress.substring(0, 6)}... */}
                                        {transaction.fromAddress.slice(0, 5)}...{transaction.fromAddress.slice(37)}
                                    </span>
                                </td>

                                <td>
                                    <span className={ transaction.toAddress == currentAccount ? style.fromAddress : ""}>
                                        {/* {transaction.toAddress.substring(0, 6)}... */}
                                        {transaction.toAddress.slice(0, 5)}...{transaction.toAddress.slice(37)}
                                    </span>
                                </td>

                                <td>
                                    {transaction.amount}
                                    <Image src={ethLogo} height={20} width={15} alt='eth' />
                                </td>

                                <td>
                                    Complete
                                </td>

                                <td>
                                    <a
                                        href={`https://rinkeby.etherscan.io/tx/${transaction.txHash}`}
                                        target='_blank'
                                        rel='noreferrer'
                                        className={style.etherscanLink}
                                    >
                                        {transaction.txHash.substring(0, 20)}...
                                    </a>
                                </td>
                                {/* {console.log(transaction)} */}
                            </tr>
                        ))}

        
                    </table>
                </div>)                
                :
                (<div className={ isLogout == true ? style.invisible : ""}>
                    <Main />
                </div>)
            }
        </div>
    )
}

export default Logado