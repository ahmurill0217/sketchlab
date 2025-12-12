import { Card, CardTitle, CardDescription } from '@/components/ui/card'
import { SectionHeader } from '@/components/ui/section-header'
import { FEATURES } from '@/lib/constants'

export function Features() {
  return (
    <section id="features" className="mt-10">
      <SectionHeader
        kicker="Features"
        title="Built for classrooms and kitchen tables."
        subtitle="Simple, repeatable, and fun enough that kids ask for 'one more'."
      />

      <div className="grid gap-2.5 md:grid-cols-3">
        {FEATURES.map((feature) => (
          <Card key={feature.title} variant="feature">
            <div className="w-[26px] h-[26px] rounded-full bg-ink text-[#fefce8] inline-flex items-center justify-center text-sm mb-0.5 shadow-dark">
              {feature.icon}
            </div>
            <CardTitle>{feature.title}</CardTitle>
            <CardDescription>{feature.description}</CardDescription>
          </Card>
        ))}
      </div>
    </section>
  )
}
