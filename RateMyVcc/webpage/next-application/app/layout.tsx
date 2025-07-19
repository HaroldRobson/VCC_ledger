import './globals.css';
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import { LocalSEO } from '@/components/seo/LocalSEO';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'CBX.earth - The Future of Carbon Credits',
  description: 'Retire carbon credits in any amount with blockchain verification. Pay lower fees than brokers. Get NFT receipts for every retirement.',
  keywords: 'carbon credits, blockchain, web3, environmental, sustainability, Etherlink L2, NFT',
  openGraph: {
    title: 'CBX.earth - The Future of Carbon Credits',
    description: 'Retire carbon credits in any amount with blockchain verification and NFT receipts.',
    url: 'https://cbx.earth',
    siteName: 'CBX.earth',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'CBX.earth - The Future of Carbon Credits',
    description: 'Retire carbon credits in any amount with blockchain verification and NFT receipts.',
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <head>
        <LocalSEO />
      </head>
      <body className={inter.className}>{children}</body>
    </html>
  );
}