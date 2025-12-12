'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { UploadDropzone } from '@/components/ui/upload-dropzone'
import { StepCard } from '@/components/ui/step-card'
import { useFileUpload } from '@/hooks/use-file-upload'
import { STEPS, HERO_BADGES, DRAWING_STYLES } from '@/lib/constants'

export function Hero() {
  const [activeSteps, setActiveSteps] = useState<number[]>([])
  const [currentStyle, setCurrentStyle] = useState<string>(DRAWING_STYLES[0])
  const { fileName, fileInputRef, triggerFileSelect, handleFileChange } = useFileUpload()

  const handleGenerateGuide = (e: React.FormEvent) => {
    e.preventDefault()

    // Animate steps one by one
    STEPS.forEach((_, index) => {
      setTimeout(() => {
        setActiveSteps((prev) => [...prev, index + 1])
      }, index * 90)
    })

    // Randomize style
    const randomStyle = DRAWING_STYLES[Math.floor(Math.random() * DRAWING_STYLES.length)]
    setCurrentStyle(randomStyle)
  }

  return (
    <section className="flex flex-col items-center text-center gap-6">
      <div className="w-full max-w-[640px]">
        {/* Label */}
        <div className="inline-flex items-center gap-2 px-1 pr-2.5 py-1 rounded-full bg-white/90 border border-dashed border-accent-yellow/90 text-[11px] text-ink-soft mb-1.5">
          <Badge variant="pill">New</Badge>
          <span className="max-w-[260px]">
            Upload one image. Get a fun, kid-friendly roadmap from simple shapes to final shine.
          </span>
        </div>

        {/* Sketch icons */}
        <div className="flex justify-center gap-2.5 mt-1.5 mb-4">
          {['🌳', '✏️', '⭐'].map((icon, i) => (
            <div
              key={i}
              className="w-10 h-10 rounded-[14px] border-2 border-dashed border-ink-muted/80 bg-muted flex items-center justify-center text-[22px]"
            >
              {icon}
            </div>
          ))}
        </div>

        {/* Title */}
        <h1 className="text-[clamp(30px,4vw,40px)] leading-[1.05] tracking-tight m-0 mb-2.5 font-semibold">
          Draw anything in six steps.
          <span className="block text-accent-pink">Made for kids. Loved by teachers.</span>
        </h1>

        {/* Badges */}
        <div className="flex flex-wrap gap-1.5 mb-4 justify-center">
          {HERO_BADGES.map((badge) => (
            <Badge key={badge.text} variant="hero">
              {badge.icon} {badge.text}
            </Badge>
          ))}
        </div>

        {/* Upload form */}
        <form
          onSubmit={handleGenerateGuide}
          className="rounded-[22px] bg-white border-dashed-yellow p-3 shadow-soft flex flex-col gap-2.5 max-w-[520px] mx-auto"
        >
          <UploadDropzone onClick={triggerFileSelect} fileName={fileName ?? undefined} />
          <input
            ref={fileInputRef}
            type="file"
            accept="image/png,image/jpeg"
            onChange={handleFileChange}
            className="hidden"
          />
          <Button type="submit" variant="hero" className="self-center">
            Make my 6-step guide <span className="text-base">⏎</span>
          </Button>
        </form>
      </div>

      {/* Preview card */}
      <div className="w-full max-w-[640px] rounded-xl bg-white border-dashed-subtle shadow-soft p-3.5 relative overflow-hidden">
        {/* Gradient overlay */}
        <div className="absolute inset-0 bg-gradient-to-br from-accent-pink/20 via-transparent to-accent-blue/20 opacity-80 pointer-events-none mix-blend-multiply" />

        <div className="relative">
          {/* Preview header */}
          <div className="flex items-center justify-between gap-2 mb-2">
            <div className="text-xs tracking-[0.18em] uppercase text-ink-muted flex items-center gap-1.5">
              <span>Preview</span>
              <span className="px-2 py-0.5 rounded-full bg-muted border border-dashed border-accent-yellow/90 text-[10px] text-ink-soft">
                Example guide
              </span>
            </div>
            <span className="px-2 py-0.5 rounded-full bg-muted border border-dashed border-accent-yellow/90 text-[10px] text-ink-soft">
              6 tiny steps
            </span>
          </div>

          {/* Preview layout */}
          <div className="grid grid-cols-1 md:grid-cols-[1.1fr_1fr] gap-2.5">
            {/* Original image placeholder */}
            <div className="rounded-[18px] border border-ink-muted/60 bg-accent-blue/20 p-2 grid gap-1.5">
              <div className="rounded-[14px] bg-gradient-to-br from-pink-300 to-red-200 min-h-[130px] relative overflow-hidden">
                <span className="absolute bottom-2.5 left-2.5 px-2 py-0.5 rounded-full bg-ink/90 text-[#fefce8] text-[10px] tracking-[0.16em] uppercase">
                  Your picture
                </span>
              </div>
              <div className="text-[11px] text-ink-soft flex justify-between items-center">
                <span>{fileName || 'cute-cat.png'}</span>
                <span>1 picture → 6 frames</span>
              </div>
            </div>

            {/* Steps grid */}
            <div className="rounded-[18px] border border-ink-muted/60 bg-muted p-2 flex flex-col gap-1.5">
              <div className="text-[11px] uppercase tracking-[0.14em] text-ink-muted flex justify-between items-center">
                <span>Step strip</span>
                <span>{currentStyle}</span>
              </div>
              <div className="grid grid-cols-3 gap-1.5">
                {STEPS.map((step) => (
                  <StepCard
                    key={step.id}
                    step={step.id}
                    name={step.name}
                    isActive={activeSteps.includes(step.id)}
                  />
                ))}
              </div>
            </div>
          </div>

          {/* Preview footer */}
          <div className="mt-2 text-[10px] text-ink-muted flex justify-between items-center">
            <span>
              <strong className="text-ink">Print it.</strong> Tape it next to the paper. Draw
              box by box.
            </span>
            <span>Perfect for stations and warm-ups.</span>
          </div>
        </div>
      </div>
    </section>
  )
}
