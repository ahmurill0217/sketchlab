import { Card, CardTitle, CardDescription } from '@/components/ui/card'
import { SectionHeader } from '@/components/ui/section-header'
import { FAQ_ITEMS } from '@/lib/constants'

export function FAQ() {
  return (
    <section id="faq" className="mt-10">
      <SectionHeader
        kicker="FAQ"
        title="Quick answers."
        subtitle="The long version is: yes, you can draw."
      />

      <div className="grid gap-2 md:grid-cols-2">
        {FAQ_ITEMS.map((item) => (
          <Card key={item.question} variant="faq">
            <CardTitle className="mb-1">{item.question}</CardTitle>
            <CardDescription>{item.answer}</CardDescription>
          </Card>
        ))}
      </div>
    </section>
  )
}
