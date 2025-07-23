'use client';

import { Inter } from 'next/font/google';
import './globals.css';
import { LocalSEO } from '@/components/seo/LocalSEO';
import { useEffect } from 'react';

const inter = Inter({ subsets: ['latin'] });

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

  return (
    <html lang="en" className="">
      <head>
        <LocalSEO />
        <script
          dangerouslySetInnerHTML={{
            __html: `
              // Set light mode as default
              document.documentElement.classList.remove('dark');
              document.documentElement.style.backgroundColor = '#ffffff';
              // Also set body class when available
              document.addEventListener('DOMContentLoaded', function() {
                document.body.classList.remove('dark');
              });
            `,
          }}
        />
      </head>
      <body className={`${inter.className}`}>
        {children}
      </body>
    </html>
  );
}