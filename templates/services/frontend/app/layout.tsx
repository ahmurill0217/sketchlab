import { Metadata } from 'next'
import '@/styles/globals.css'
import { Providers } from '@/providers/app-providers'
import Footer from '@/components/navigation/Footer'
import NavBar from '@/components/navigation/NavBar'

export const metadata: Metadata = {
  title: 'Avidity Biosciences',
  description:
    'Avidity Biosciences is a biotechnology company specializing in RNA therapeutics.',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <head>
        <link rel="icon" href="/favicon.ico" sizes="any" />
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link
          rel="preconnect"
          href="https://fonts.gstatic.com"
          crossOrigin=""
        />
        <link
          href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100..900;1,100..900&display=swap"
          rel="stylesheet"
        />
      </head>
      <body>
        <Providers>
          <main className="bg-background w-full">
            <NavBar />
            {children}
            <Footer />
          </main>
        </Providers>
      </body>
    </html>
  )
}
