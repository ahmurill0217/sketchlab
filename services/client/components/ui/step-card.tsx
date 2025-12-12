'use client'

import { cn } from '@/lib/utils'

interface StepCardProps {
  step: number
  name: string
  isActive?: boolean
  className?: string
}

const PHASE_LABELS: Record<number, string> = {
  1: 'Shapes',
  2: 'Volume',
  3: 'Lines',
  4: 'Details',
  5: 'Shadow',
  6: 'Shine',
}

export function StepCard({ step, name, isActive = false, className }: StepCardProps) {
  return (
    <div
      className={cn(
        'rounded-sm bg-white border border-dashed border-ink-muted/70 p-1.5 text-[10px] text-ink-soft transition-all duration-100',
        isActive && 'border-accent-pink shadow-md -translate-y-0.5',
        className
      )}
    >
      <div className="rounded-[9px] bg-muted h-[50px] relative overflow-hidden">
        <div className="absolute inset-2.5 rounded-[9px] border border-dashed border-ink-muted/70" />
        <span className="absolute bottom-1.5 left-1.5 px-1.5 py-0.5 rounded-full bg-ink text-[#fefce8] text-[9px]">
          {PHASE_LABELS[step]}
        </span>
      </div>
      <div className="flex justify-between items-center gap-1 mt-1">
        <strong className="text-ink">{step}</strong>
        <span className="text-ink-muted">{name}</span>
      </div>
    </div>
  )
}
