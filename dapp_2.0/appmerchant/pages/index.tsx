import type { NextPage } from 'next'
import InitialStuffs from '../components/initialStuffs'
import Login from '../components/Login'
import Header from '../components/Header'
import Main from '../components/Main'
import TransactionHistory from '../components/TransactionHistory'
import Logado from '../components/Logado'

const style = {
  wrapper: `h-screen max-h-screen h-min-screen w-screen bg-[#FFFFFF] text-white select-none flex flex-col`,
}

const Home: NextPage = () => {
  return (
    <div className={style.wrapper}>
      {/* <Login /> */}
      <Header />
      {/* <Main /> */}
      {/* <TransactionHistory /> */}
      <Logado />
    </div>
  )
}

export default Home
