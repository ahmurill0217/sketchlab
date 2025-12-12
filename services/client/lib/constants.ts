export const STEPS = [
  { id: 1, name: 'Shapes', phase: 1 },
  { id: 2, name: 'Volume', phase: 2 },
  { id: 3, name: 'Lines', phase: 3 },
  { id: 4, name: 'Details', phase: 4 },
  { id: 5, name: 'Shadow', phase: 5 },
  { id: 6, name: 'Shine', phase: 6 },
] as const

export const FEATURES = [
  {
    icon: '🎒',
    title: 'Kid-friendly text',
    description: 'Short, simple instructions written for ages 8+.',
  },
  {
    icon: '🎨',
    title: 'Any style',
    description: 'Photos, doodles, anime, comics – Sketch Labs adjusts.',
  },
  {
    icon: '🖨️',
    title: 'Print & share',
    description: 'Hand out guides to the whole class in seconds.',
  },
] as const

export const HOW_IT_WORKS = [
  { step: 1, text: 'Upload a picture.' },
  { step: 2, text: 'We make 6 boxes.' },
  { step: 3, text: 'You draw box by box.' },
] as const

export const HERO_BADGES = [
  { icon: '✏️', text: 'Step-by-step' },
  { icon: '🎨', text: 'Classroom-ready' },
  { icon: '🧠', text: 'LLM-powered coach' },
  { icon: '🖨️', text: 'Printable sheets' },
] as const

export const FAQ_ITEMS = [
  {
    question: 'What is Sketch Labs?',
    answer:
      'Sketch Labs turns any image into a simple 6-step drawing roadmap: shapes → volume → lines → details → shadow → shine.',
  },
  {
    question: 'Who is this for?',
    answer:
      'Made for kids, beginners, and "I can\'t draw" humans. If you can hold a pencil, you\'re in.',
  },
  {
    question: 'How does it work?',
    answer:
      'Upload one image and Sketch Labs generates a step-by-step guide that starts super simple and builds up to a finished drawing.',
  },
  {
    question: 'What kind of images can I upload?',
    answer:
      'Photos, screenshots, cartoons, toys, pets, people — anything with a clear subject works best.',
  },
  {
    question: 'What file types do you support?',
    answer: 'JPG and PNG are supported. HEIC support is coming soon.',
  },
  {
    question: 'Is there a size limit for uploads?',
    answer:
      'Yes, keep it under 10MB for the smoothest results. If it fails, just resize and try again.',
  },
  {
    question: 'Do you work with photos of people or pets?',
    answer:
      'Yes. Faces and pets work great — clean lighting and a simple background help a lot.',
  },
  {
    question: 'What do I get back?',
    answer:
      'You get the 6 steps plus quick tips for what to focus on in each step.',
  },
  {
    question: 'How long does it take?',
    answer: 'Usually under a minute.',
  },
  {
    question: 'Can I edit or regenerate the steps?',
    answer:
      'Yes. Hit Regenerate to get a new version, or choose a simpler or more detailed guide.',
  },
  {
    question: 'Does it work on my phone or tablet?',
    answer:
      'Yes. Sketch Labs runs in your browser on iPhone, iPad, Android, and desktop.',
  },
  {
    question: 'Is it kid-safe?',
    answer:
      'Yes. We filter unsafe content and keep the instructions kid-friendly and simple.',
  },
  {
    question: 'Do you store my uploaded images?',
    answer:
      "By default, we only keep your image long enough to generate your guide, then it's deleted.",
  },
  {
    question: 'Do you use my images to train AI?',
    answer: 'No. Your uploads are used only to generate your guide.',
  },
  {
    question: 'Can I share or print the guide?',
    answer:
      'Yes — share it, print it, and use it at home or in class. Commercial bundles may require a license later on.',
  },
  {
    question: 'What does it cost?',
    answer:
      "It's free. Paid plans will unlock saved guides and faster image generation.",
  },
] as const

export const NAV_LINKS = [
  { href: '#features', label: 'Features' },
  { href: '#how-it-works', label: 'How it works' },
  { href: '#faq', label: 'FAQ' },
] as const

export const DRAWING_STYLES = [
  'Pencil + soft color',
  'Marker + bold lines',
  'Crayon + texture',
  'Clean pencil sketch',
] as const
