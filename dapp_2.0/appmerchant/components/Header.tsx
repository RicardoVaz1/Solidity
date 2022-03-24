import { useEffect, useState, useContext } from 'react'
import { FiLogOut } from 'react-icons/fi'
import { TransactionContext } from '../context/TransactionContext'
import { client } from '../lib/sanityClient'

const style = {
  wrapper: `p-4 w-screen items-center`,
  headerLogo: `flex w-1/4 items-center justify-start`,
  nav: `flex-1 flex justify-center items-center`,
  navItemsContainer: `flex bg-[#191B1F] rounded-3xl`,
  navItem: `px-4 py-2 m-1 flex items-center text-lg font-semibold text-[0.9rem] cursor-pointer rounded-3xl`,
  activeNavItem: `bg-[#20242A]`,
  buttonsContainer: `flex w-1/4 justify-end items-center`,
  button: `flex items-center bg-[#191B1F] rounded-2xl mx-2 text-[0.9rem] font-semibold cursor-pointer`,
  buttonPadding: `p-2`,
  buttonTextContainer: `h-8 flex items-center`,
  buttonIconContainer: `flex items-center justify-center w-8 h-8`,
  buttonAccent: `bg-[#172A42] border border-[#163256] hover:border-[#234169] h-full rounded-2xl flex items-center justify-center text-[#4F90EA]`,
  invisible: `hidden`,
}

const Header = () => {
  const [userName, setUserName] = useState<string>()
  const { connectWallet, currentAccount, Logout, isLogout } = useContext(TransactionContext)

  useEffect(() => {
    if (currentAccount) {
      ;(async () => {
        const query = `
        *[_type=="users" && _id == "${currentAccount}"] {
          userName,
        }
        `
        const clientRes = await client.fetch(query)

        if (!(clientRes[0].userName == 'Unnamed')) {
          setUserName(clientRes[0].userName)
        } else {
          setUserName(
            `${currentAccount.slice(0, 7)}...${currentAccount.slice(35)}`,
          )
        }
      })()
    }
  }, [currentAccount])

  return (
    <div className={style.wrapper}>
      <div className={style.buttonsContainer} style={{float: "right"}}>
        {currentAccount ? (
          <div className={`${style.button} ${style.buttonPadding}`}>
            <div className={style.buttonTextContainer}>{userName}</div>
          </div>
        ) : (
          <div onClick={() => connectWallet()} className={`${style.button} ${style.buttonPadding}`}>
            <div className={`${style.buttonAccent} ${style.buttonPadding}`}>
              Connect Wallet
            </div>
          </div>
        )}

        <div onClick={() => Logout()} 
          className={ isLogout == true ? style.invisible : `${style.button} ${style.buttonPadding}`}
        
          // className={`${style.button} ${style.buttonPadding}`}
          >

          <div className={`${style.buttonIconContainer} mx-2`}>
            <FiLogOut />
          </div>
        </div>
      </div>
      {/* {console.log(userName)} */}
    </div>
  )
}

export default Header
