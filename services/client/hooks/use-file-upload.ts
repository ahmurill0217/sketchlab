'use client'

import { useState, useRef, useCallback } from 'react'

interface UseFileUploadOptions {
  accept?: string
  maxSize?: number // in bytes
  onFileSelect?: (file: File) => void
  onError?: (error: string) => void
}

interface UseFileUploadReturn {
  file: File | null
  fileName: string | null
  fileInputRef: React.RefObject<HTMLInputElement | null>
  triggerFileSelect: () => void
  handleFileChange: (event: React.ChangeEvent<HTMLInputElement>) => void
  clearFile: () => void
  isValidFile: boolean
}

export function useFileUpload({
  accept = 'image/png,image/jpeg',
  maxSize = 10 * 1024 * 1024, // 10MB default
  onFileSelect,
  onError,
}: UseFileUploadOptions = {}): UseFileUploadReturn {
  const [file, setFile] = useState<File | null>(null)
  const fileInputRef = useRef<HTMLInputElement | null>(null)

  const triggerFileSelect = useCallback(() => {
    fileInputRef.current?.click()
  }, [])

  const validateFile = useCallback(
    (file: File): boolean => {
      // Check file type
      const acceptedTypes = accept.split(',').map((t) => t.trim())
      const isValidType = acceptedTypes.some((type) => {
        if (type.startsWith('.')) {
          return file.name.toLowerCase().endsWith(type)
        }
        return file.type === type || file.type.startsWith(type.replace('/*', '/'))
      })

      if (!isValidType) {
        onError?.(`Invalid file type. Please upload: ${accept}`)
        return false
      }

      // Check file size
      if (file.size > maxSize) {
        const maxSizeMB = Math.round(maxSize / (1024 * 1024))
        onError?.(`File too large. Maximum size is ${maxSizeMB}MB`)
        return false
      }

      return true
    },
    [accept, maxSize, onError]
  )

  const handleFileChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      const selectedFile = event.target.files?.[0]
      if (!selectedFile) return

      if (validateFile(selectedFile)) {
        setFile(selectedFile)
        onFileSelect?.(selectedFile)
      }

      // Reset input so same file can be selected again
      event.target.value = ''
    },
    [validateFile, onFileSelect]
  )

  const clearFile = useCallback(() => {
    setFile(null)
  }, [])

  return {
    file,
    fileName: file?.name ?? null,
    fileInputRef,
    triggerFileSelect,
    handleFileChange,
    clearFile,
    isValidFile: file !== null,
  }
}
