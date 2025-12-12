import { cn } from '@/lib/utils'

interface CardProps {
  children: React.ReactNode
  variant?: 'default' | 'feature' | 'faq' | 'how' | 'preview'
  className?: string
}

export function Card({ children, variant = 'default', className }: CardProps) {
  return (
    <div
      className={cn(
        'rounded-lg bg-white',
        {
          'border-2 border-dashed border-ink-muted/70 p-3 text-sm text-ink-soft':
            variant === 'default',
          'border-2 border-dashed border-orange-200/90 p-3 text-sm text-ink-soft flex flex-col gap-1':
            variant === 'feature',
          'rounded-md border-2 border-dashed border-ink-muted/70 p-2.5 text-sm text-ink-soft':
            variant === 'faq',
          'rounded-lg border-2 border-dashed border-ink-muted/80 p-3 text-center text-sm text-ink-soft flex flex-col items-center justify-center gap-1 min-h-[110px]':
            variant === 'how',
          'rounded-xl border-2 border-dashed border-ink-muted/70 shadow-soft p-3.5 relative overflow-hidden':
            variant === 'preview',
        },
        className
      )}
    >
      {children}
    </div>
  )
}

interface CardTitleProps {
  children: React.ReactNode
  className?: string
}

export function CardTitle({ children, className }: CardTitleProps) {
  return (
    <h3 className={cn('text-sm font-semibold text-ink m-0', className)}>
      {children}
    </h3>
  )
}

interface CardDescriptionProps {
  children: React.ReactNode
  className?: string
}

export function CardDescription({ children, className }: CardDescriptionProps) {
  return <p className={cn('text-sm text-ink-soft m-0', className)}>{children}</p>
}
