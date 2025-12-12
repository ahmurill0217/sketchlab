import Link from 'next/link'
import Image from 'next/image'

export default function NavBar() {
  return (
    <div className="p-4 border-b border-border top-0 z-50 w-full bg-white">
      <div className="max-w-[75rem] mx-auto flex w-full justify-between items-center">
        <div className="logo">
          <Link href="/">
            <Image
              src="/images/avidity-biosciences-logo.png"
              alt="Avidity Biosciences"
              width={100}
              height={100}
            />
          </Link>
        </div>
      </div>
    </div>
  )
}
