import { Card } from '@/components/ui/card'
import { SectionHeader } from '@/components/ui/section-header'
import { HOW_IT_WORKS } from '@/lib/constants'

export function HowItWorks() {
  return (
    <section id="how-it-works" className="mt-10">
      <SectionHeader
        kicker="How it works"
        title="3 moves. Then you draw."
        subtitle="We keep the tech hidden and the steps clear."
      />

      <div className="grid grid-cols-3 gap-2.5 max-w-[520px] mx-auto">
        {HOW_IT_WORKS.map((item) => (
          <Card key={item.step} variant="how">
            <div className="w-8 h-8 rounded-full bg-ink text-[#fefce8] flex items-center justify-center font-bold mb-0.5 shadow-dark">
              {item.step}
            </div>
            <div className="text-[13px] text-ink">{item.text}</div>
          </Card>
        ))}
      </div>
    </section>
  )
}
