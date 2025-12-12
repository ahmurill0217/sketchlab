// 404

import Link from 'next/link'
import { Button } from '@/components/ui/button'

export default function NotFound() {
  return (
    <div className="min-h-[calc(100vh-79.88px-186.7px)] flex items-center justify-center text-center">
      <div>
        <h2>404 😅</h2>
        <p className="pt-2 pb-4">
          Oops! You stumbled upon a page that doesn't exist.
        </p>
        <Button asChild>
          <Link href="/">Return Home</Link>
        </Button>
      </div>
    </div>
  )
}
