'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'

export function CTA() {
  const [email, setEmail] = useState('')
  const [isSubmitted, setIsSubmitted] = useState(false)

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    // TODO: Integrate with backend/email service
    setIsSubmitted(true)
  }

  return (
    <section id="waitlist" className="mt-8 rounded-xl bg-ink text-[#fefce8] p-4 md:p-5 grid gap-2.5 md:grid-cols-[1.2fr_1fr] md:items-center">
      <div>
        <h2 className="m-0 mb-1 text-xl tracking-tight font-semibold">
          Want Sketch Labs in your classroom?
        </h2>
        <p className="text-[13px] max-w-[30rem] text-gray-300 m-0">
          Leave your email and we'll invite teachers, parents, and early testers first.
        </p>
      </div>
      <div>
        <form onSubmit={handleSubmit} className="flex flex-wrap gap-2 items-center">
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="you@example.com"
            required
            className="flex-1 min-w-[180px] px-4 py-2 rounded-full bg-white/10 border border-white/20 text-white placeholder:text-white/50 text-sm focus:outline-none focus:ring-2 focus:ring-accent-orange"
          />
          <Button type="submit" variant="cta">
            Join the early list <span>→</span>
          </Button>
        </form>
        <div className="mt-2 text-xs text-gray-400">
          {isSubmitted
            ? "You're on the list. Time to sharpen the pencils."
            : 'No spam. Just sketchy updates and new prompts.'}
        </div>
      </div>
    </section>
  )
}
