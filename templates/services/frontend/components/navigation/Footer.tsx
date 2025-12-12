import Link from 'next/link'
import Image from 'next/image'

const Footer = () => {
  return (
    <footer className="bg-gray-900 text-white py-12">
      <div className="max-w-[50rem] mx-auto px-6 w-full text-center">
        <div className="text-center">
          <Link href="/">
            <Image
              src="/images/avidity-biosciences-logo.png"
              alt="Avidity Biosciences"
              width={150}
              height={150}
              className="mx-auto"
            />
          </Link>
          <p className="text-center text-gray-500 text-sm">
            © 2025 Avidity Biosciences
          </p>
        </div>
      </div>
    </footer>
  )
}

export default Footer
