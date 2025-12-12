import { Hero } from '@/components/sections/Hero'
import { Features } from '@/components/sections/Features'
import { HowItWorks } from '@/components/sections/HowItWorks'
import { FAQ } from '@/components/sections/FAQ'
import { CTA } from '@/components/sections/CTA'

export default function Home() {
  return (
    <>
      <Hero />
      <Features />
      <HowItWorks />
      <FAQ />
      <CTA />
    </>
  )
}
