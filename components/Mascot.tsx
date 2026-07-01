export default function Mascot({ size = 32, className = "" }: { size?: number; className?: string }) {
  return (
    <svg
      viewBox="0 0 128 128"
      width={size}
      height={size}
      className={className}
      xmlns="http://www.w3.org/2000/svg"
      style={{ display: "block" }}
      aria-hidden="true"
    >
      <defs>
        <linearGradient id="senseiBody" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#2DD4BF" />
          <stop offset="1" stopColor="#0D9488" />
        </linearGradient>
        <linearGradient id="senseiBand" x1="0" y1="0" x2="1" y2="0">
          <stop offset="0" stopColor="#6366F1" />
          <stop offset="1" stopColor="#4F46E5" />
        </linearGradient>
      </defs>
      {/* ear tufts */}
      <circle cx="41" cy="41" r="11" fill="#0D9488" />
      <circle cx="87" cy="41" r="11" fill="#0D9488" />
      {/* head */}
      <circle cx="64" cy="72" r="41" fill="url(#senseiBody)" />
      {/* face patch */}
      <ellipse cx="64" cy="80" rx="29" ry="27" fill="#ECFEFF" />
      {/* cheeks */}
      <circle cx="41" cy="88" r="5" fill="#FB7185" opacity="0.55" />
      <circle cx="87" cy="88" r="5" fill="#FB7185" opacity="0.55" />
      {/* eyes */}
      <circle cx="52" cy="77" r="8.5" fill="#fff" />
      <circle cx="76" cy="77" r="8.5" fill="#fff" />
      <circle cx="53.5" cy="78.5" r="4.4" fill="#0F172A" />
      <circle cx="77.5" cy="78.5" r="4.4" fill="#0F172A" />
      <circle cx="51.8" cy="76.8" r="1.5" fill="#fff" />
      <circle cx="75.8" cy="76.8" r="1.5" fill="#fff" />
      {/* beak */}
      <path d="M64 83 L59 90 Q64 93 69 90 Z" fill="#FBBF24" />
      {/* headband */}
      <path d="M24 57 Q64 47 104 57 L104 67 Q64 58 24 67 Z" fill="url(#senseiBand)" />
      {/* knot + tails on left */}
      <path d="M25 60 L8 52 Q6 58 13 63 Z" fill="#4338CA" />
      <path d="M25 64 L7 71 Q11 76 17 72 Z" fill="#4338CA" />
      <circle cx="25" cy="62" r="5.5" fill="#6366F1" />
      {/* little spark */}
      <path d="M104 30 l2.2 5 5 2.2 -5 2.2 -2.2 5 -2.2 -5 -5 -2.2 5 -2.2 Z" fill="#FBBF24" />
    </svg>
  );
}
