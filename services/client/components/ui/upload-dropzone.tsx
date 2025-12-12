'use client'

import { cn } from '@/lib/utils'

interface UploadDropzoneProps {
  onClick?: () => void
  fileName?: string
  className?: string
}

export function UploadDropzone({ onClick, fileName, className }: UploadDropzoneProps) {
  return (
    <div className={cn('flex gap-2.5 items-center flex-wrap', className)}>
      <div
        onClick={onClick}
        className="flex-1 min-w-[200px] rounded-[18px] border-2 border-dashed border-ink-muted/90 p-2.5 bg-stripes flex gap-2.5 items-center cursor-pointer transition-all duration-100 hover:-translate-y-0.5 hover:shadow-lg hover:shadow-amber-300/50 hover:border-accent-pink"
      >
        <div className="w-[30px] h-[30px] rounded-full bg-ink text-[#fefce8] flex items-center justify-center text-lg flex-shrink-0">
          ↑
        </div>
        <div>
          <div className="text-[13px] font-semibold mb-0.5">Drop a PNG or JPG</div>
          <div className="text-[11px] text-ink-muted">
            Pets, characters, objects – all welcome.
          </div>
        </div>
      </div>
      {fileName && (
        <div className="text-[11px] text-ink-muted">Selected: {fileName}</div>
      )}
    </div>
  )
}
