import React from 'react'
import Head from 'next/head'
import Image from 'next/image'
import { useEffect, useState } from 'react'
import { useRouter } from 'next/router'

const style = {
    wrapper: `w-screen flex items-center justify-center mt-14`,
    content: `bg-[#191B1F] rounded-2xl`,
    buttonPadding: `p-2`,
    buttonAccent: `bg-[#FFFFFF] border border-[#163256] hover:border-[#234169] h-full rounded-2xl flex items-center justify-center text-[#4F90EA]`,
}



const Login = () => {
    const [userName, setUserName] = useState<string>()
    //const { connectWallet, currentAccount } = useContext(TransactionContext)
    const router = useRouter()

    function connectWallet() {
        console.log("Connected!");
        router.push(`/home`)
    }

    return (
        <div>
            <Head>
                <title>Login</title>
                <link rel="icon" href="/favicon.ico" />
            </Head>

            <div className={style.wrapper}>
                <div className={style.content}>
                    <div
                        onClick={() => connectWallet()}
                        className={`${style.buttonPadding}`}
                    >
                        <div className={`${style.buttonAccent} ${style.buttonPadding}`}>
                        Connect Wallet
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}

export default Login