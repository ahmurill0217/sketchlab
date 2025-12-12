import { Metadata } from 'next'
import '@/styles/globals.css'
import { Providers } from '@/providers/app-providers'
import { Header } from '@/components/layout/Header'
import { Footer } from '@/components/layout/Footer'

export const metadata: Metadata = {
  title: 'Sketch Labs – Draw Anything in 6 Steps',
  description:
    'Upload a picture and get a fun 6-step drawing guide kids can follow in class or at home.',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>
        <Providers>
          <div className="min-h-screen">
            <Header />
            <main className="max-w-[1120px] mx-auto px-4 py-7 md:pt-10 pb-14">
              {children}
            </main>
            <Footer />
          </div>
        </Providers>
      </body>
    </html>
  )
}
