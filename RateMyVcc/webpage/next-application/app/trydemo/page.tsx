'use client';

import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { ExternalLink, Wallet, Zap, ShoppingCart, Receipt, ArrowRight, Copy, CheckCircle, Play } from 'lucide-react';
import Link from 'next/link';
import { useEffect } from 'react';
import { Navigation } from '@/components/ui/Navigation';
import { ThemeProvider } from '@/components/ui/ThemeProvider';
import { motion } from 'framer-motion';
import { useAnimateOnce } from '../../hooks/useOneDirectionalAnimation';

// Type declaration for MetaMask
declare global {
  interface Window {
    ethereum?: {
      request: (args: { method: string; params?: any[] }) => Promise<any>;
      isMetaMask?: boolean;
    };
  }
}

export default function TryDemoPage() {
  const titleAnimation = useAnimateOnce<HTMLDivElement>();
  const setupAnimation = useAnimateOnce<HTMLDivElement>();
  const dappsAnimation = useAnimateOnce<HTMLDivElement>();
  const howItWorksAnimation = useAnimateOnce<HTMLDivElement>();
  const ctaAnimation = useAnimateOnce<HTMLDivElement>();

  // Set document title and meta description on the client side
  useEffect(() => {
    document.title = 'Try CBX Demo - Live Carbon Credit Trading';
    const metaDescription = document.querySelector('meta[name="description"]');
    if (metaDescription) {
      metaDescription.setAttribute('content', 'Experience our live DAPPs on Etherlink L2. Buy carbon credits and view retirement receipts with full blockchain transparency.');
    } else {
      const meta = document.createElement('meta');
      meta.name = 'description';
      meta.content = 'Experience our live DAPPs on Etherlink L2. Buy carbon credits and view retirement receipts with full blockchain transparency.';
      document.head.appendChild(meta);
    }
  }, []);

  const addEtherlinkNetwork = async () => {
    try {
      if (typeof window !== 'undefined' && window.ethereum) {
        await window.ethereum.request({
          method: 'wallet_addEthereumChain',
          params: [{
            chainId: '0x1F4FB',
            chainName: 'Etherlink Testnet',
            rpcUrls: ['https://node.ghostnet.etherlink.com'],
            nativeCurrency: {
              name: 'XTZ',
              symbol: 'XTZ',
              decimals: 18
            }
          }]
        });
      } else {
        alert('MetaMask is not installed. Please install MetaMask first.');
      }
    } catch (error) {
      console.error('Error adding network:', error);
    }
  };

  return (
    <ThemeProvider>
      <div className="min-h-screen bg-white dark:bg-[#171717]">
        <Navigation navItems={[]} showWaitlistButton={false} />
        
        {/* Hero Section */}
        <section className="pt-32 pb-20 bg-white dark:bg-[#171717]">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <motion.div
              ref={titleAnimation.ref}
              initial={{ opacity: 0, y: 20 }}
              animate={titleAnimation.isVisible ? { opacity: 1, y: 0 } : { opacity: 0, y: 20 }}
              transition={{ duration: 0.2, ease: "easeOut" }}
              className="text-center mb-16"
            >
              <div className="inline-flex items-center bg-green-500/20 border border-green-500/30 rounded-full px-6 py-2 mb-6">
                <Zap className="w-4 h-4 text-green-400 mr-2" />
                <span className="text-green-600 dark:text-green-400 font-medium text-sm">Live DAPPs Now Available</span>
              </div>
              
              <h1 className="text-5xl md:text-7xl font-bold text-gray-900 dark:text-white mb-8 leading-tight">
                Try CBX <span className="bg-gradient-to-r from-green-500 to-emerald-500 bg-clip-text text-transparent dark:from-green-400 dark:to-emerald-400">Live Demo</span>
              </h1>
              
              <p className="text-xl md:text-2xl text-gray-600 dark:text-gray-300 mb-8 max-w-4xl mx-auto leading-relaxed">
                Experience our live decentralized applications on Etherlink L2. 
                Buy carbon credits and view immutable retirement receipts with full blockchain transparency.
              </p>
              
              <div className="bg-yellow-500/10 border border-yellow-500/20 rounded-2xl p-6 max-w-3xl mx-auto">
                <p className="text-yellow-700 dark:text-yellow-300 text-base">
                  <strong>Demo Environment:</strong> These are live DAPPs running on Etherlink L2 testnet. 
                  Use test tokens only - no real money required!
                </p>
              </div>
            </motion.div>
          </div>
        </section>

        {/* Setup Guide Section */}
        <section className="py-24 bg-white dark:bg-[#171717]">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <motion.div
              ref={setupAnimation.ref}
              initial={{ opacity: 0, y: 20 }}
              animate={setupAnimation.isVisible ? { opacity: 1, y: 0 } : { opacity: 0, y: 20 }}
              transition={{ duration: 0.2, ease: "easeOut" }}
            >
              <div className="text-center mb-16">
                <h2 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-6">
                  <span className="bg-gradient-to-r from-green-500 to-emerald-500 bg-clip-text text-transparent dark:from-green-400 dark:to-emerald-400">
                    Quick Setup
                  </span> Guide
                </h2>
                <p className="text-xl text-gray-600 dark:text-gray-400 max-w-2xl mx-auto">
                  Get started in 3 simple steps
                </p>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                {/* Step 1 */}
                <div className="bg-white dark:bg-[#1A1A1A] rounded-2xl p-8 border border-gray-200 dark:border-gray-800 shadow-lg">
                  <div className="flex items-center mb-6">
                    <div className="w-10 h-10 bg-green-500 rounded-full flex items-center justify-center text-white font-bold text-lg mr-4">
                      1
                    </div>
                    <h3 className="text-xl font-semibold text-gray-900 dark:text-white">Install MetaMask</h3>
                  </div>
                  <p className="text-gray-600 dark:text-gray-400 mb-6">
                    Install the MetaMask browser extension if you haven't already.
                  </p>
                  <Button 
                    asChild 
                    variant="outline" 
                    className="w-full border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800"
                  >
                    <a href="https://metamask.io/" target="_blank" rel="noopener noreferrer">
                      Get MetaMask <ExternalLink className="w-4 h-4 ml-2" />
                    </a>
                  </Button>
                </div>

                {/* Step 2 */}
                <div className="bg-white dark:bg-[#1A1A1A] rounded-2xl p-8 border border-gray-200 dark:border-gray-800 shadow-lg">
                  <div className="flex items-center mb-6">
                    <div className="w-10 h-10 bg-green-500 rounded-full flex items-center justify-center text-white font-bold text-lg mr-4">
                      2
                    </div>
                    <h3 className="text-xl font-semibold text-gray-900 dark:text-white">Add Etherlink L2</h3>
                  </div>
                  <p className="text-gray-600 dark:text-gray-400 mb-4">
                    Add the Etherlink L2 testnet to your MetaMask.
                  </p>
                  <div className="bg-gray-100 dark:bg-gray-800 rounded-lg p-4 text-sm text-gray-700 dark:text-gray-300 mb-6 space-y-1">
                    <div><strong>Network:</strong> Etherlink Testnet</div>
                    <div><strong>RPC:</strong> https://node.ghostnet.etherlink.com</div>
                    <div><strong>Chain ID:</strong> 128123</div>
                    <div><strong>Currency:</strong> XTZ</div>
                  </div>
                  <Button 
                    onClick={addEtherlinkNetwork}
                    className="w-full bg-green-600 hover:bg-green-700 text-white"
                  >
                    Add to MetaMask
                  </Button>
                </div>

                {/* Step 3 */}
                <div className="bg-white dark:bg-[#1A1A1A] rounded-2xl p-8 border border-gray-200 dark:border-gray-800 shadow-lg">
                  <div className="flex items-center mb-6">
                    <div className="w-10 h-10 bg-green-500 rounded-full flex items-center justify-center text-white font-bold text-lg mr-4">
                      3
                    </div>
                    <h3 className="text-xl font-semibold text-gray-900 dark:text-white">Get Test Tokens</h3>
                  </div>
                  <p className="text-gray-600 dark:text-gray-400 mb-6">
                    Get free XTZ testnet tokens from the faucet.
                  </p>
                  <Button 
                    asChild 
                    className="w-full bg-blue-600 hover:bg-blue-700 text-white"
                  >
                    <a href="https://faucet.ghostnet.teztnets.xyz/" target="_blank" rel="noopener noreferrer">
                      Get Faucet Tokens <Zap className="w-4 h-4 ml-2" />
                    </a>
                  </Button>
                </div>
              </div>
            </motion.div>
          </div>
        </section>

        {/* DAPPs Section */}
        <section className="py-24 bg-white dark:bg-[#171717]">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <motion.div
              ref={dappsAnimation.ref}
              initial={{ opacity: 0, y: 20 }}
              animate={dappsAnimation.isVisible ? { opacity: 1, y: 0 } : { opacity: 0, y: 20 }}
              transition={{ duration: 0.2, ease: "easeOut" }}
            >
              <div className="text-center mb-16">
                <h2 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-6">
                  Live <span className="bg-gradient-to-r from-green-500 to-emerald-500 bg-clip-text text-transparent dark:from-green-400 dark:to-emerald-400">DAPPs</span>
                </h2>
                <p className="text-xl text-gray-600 dark:text-gray-400 max-w-3xl mx-auto">
                  Experience the future of carbon markets with our live decentralized applications
                </p>
              </div>

              <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 mb-16">
                {/* Buy DAPP */}
                <div className="bg-white dark:bg-[#1A1A1A] rounded-3xl p-8 border border-gray-200 dark:border-gray-800 shadow-lg">
                  <div className="flex items-center mb-6">
                    <div className="w-16 h-16 bg-green-500/20 rounded-2xl flex items-center justify-center mr-4">
                      <ShoppingCart className="w-8 h-8 text-green-600 dark:text-green-400" />
                    </div>
                    <div>
                      <h3 className="text-2xl font-bold text-gray-900 dark:text-white">Carbon Credit Marketplace</h3>
                      <p className="text-gray-600 dark:text-gray-400">Browse and purchase verified carbon credits</p>
                    </div>
                  </div>

                  <div className="space-y-4 mb-8">
                    <div className="flex items-start space-x-3">
                      <CheckCircle className="w-5 h-5 text-green-500 mt-0.5 flex-shrink-0" />
                      <div>
                        <h4 className="text-gray-900 dark:text-white font-medium">Live Carbon Credits</h4>
                        <p className="text-gray-600 dark:text-gray-400 text-sm">Browse real VCS-verified carbon credit projects with transparent ratings</p>
                      </div>
                    </div>
                    <div className="flex items-start space-x-3">
                      <CheckCircle className="w-5 h-5 text-green-500 mt-0.5 flex-shrink-0" />
                      <div>
                        <h4 className="text-gray-900 dark:text-white font-medium">Instant Settlement</h4>
                        <p className="text-gray-600 dark:text-gray-400 text-sm">Purchase any amount (as low as 0.01 tonnes) with immediate on-chain settlement</p>
                      </div>
                    </div>
                    <div className="flex items-start space-x-3">
                      <CheckCircle className="w-5 h-5 text-green-500 mt-0.5 flex-shrink-0" />
                      <div>
                        <h4 className="text-gray-900 dark:text-white font-medium">Low Fees</h4>
                        <p className="text-gray-600 dark:text-gray-400 text-sm">0.5-2% total fees vs 20-40% with traditional brokers</p>
                      </div>
                    </div>
                  </div>

                  <Button 
                    asChild 
                    className="w-full bg-green-600 hover:bg-green-700 text-white shadow-lg shadow-green-600/25"
                    size="lg"
                  >
                    <a href="https://buy.cbx.earth" target="_blank" rel="noopener noreferrer">
                      Try Marketplace <ArrowRight className="w-5 h-5 ml-2" />
                    </a>
                  </Button>
                </div>

                {/* Receipts DAPP */}
                <div className="bg-white dark:bg-[#1A1A1A] rounded-3xl p-8 border border-gray-200 dark:border-gray-800 shadow-lg">
                  <div className="flex items-center mb-6">
                    <div className="w-16 h-16 bg-blue-500/20 rounded-2xl flex items-center justify-center mr-4">
                      <Receipt className="w-8 h-8 text-blue-600 dark:text-blue-400" />
                    </div>
                    <div>
                      <h3 className="text-2xl font-bold text-gray-900 dark:text-white">Retirement Receipts</h3>
                      <p className="text-gray-600 dark:text-gray-400">View immutable NFT receipts</p>
                    </div>
                  </div>

                  <div className="space-y-4 mb-8">
                    <div className="flex items-start space-x-3">
                      <CheckCircle className="w-5 h-5 text-blue-500 mt-0.5 flex-shrink-0" />
                      <div>
                        <h4 className="text-gray-900 dark:text-white font-medium">NFT Receipts</h4>
                        <p className="text-gray-600 dark:text-gray-400 text-sm">Each retirement generates an immutable NFT receipt as proof</p>
                      </div>
                    </div>
                    <div className="flex items-start space-x-3">
                      <CheckCircle className="w-5 h-5 text-blue-500 mt-0.5 flex-shrink-0" />
                      <div>
                        <h4 className="text-gray-900 dark:text-white font-medium">Full Transparency</h4>
                        <p className="text-gray-600 dark:text-gray-400 text-sm">View complete transaction history and project details on-chain</p>
                      </div>
                    </div>
                    <div className="flex items-start space-x-3">
                      <CheckCircle className="w-5 h-5 text-blue-500 mt-0.5 flex-shrink-0" />
                      <div>
                        <h4 className="text-gray-900 dark:text-white font-medium">Tamper-Proof</h4>
                        <p className="text-gray-600 dark:text-gray-400 text-sm">Unlike PDF certificates, blockchain receipts cannot be forged</p>
                      </div>
                    </div>
                  </div>

                  <Button 
                    asChild 
                    className="w-full bg-blue-600 hover:bg-blue-700 text-white shadow-lg shadow-blue-600/25"
                    size="lg"
                  >
                    <a href="https://receipts.cbx.earth" target="_blank" rel="noopener noreferrer">
                      View Receipts <ArrowRight className="w-5 h-5 ml-2" />
                    </a>
                  </Button>
                </div>
              </div>
            </motion.div>
          </div>
        </section>

        {/* How it Works */}
        <section className="py-24 bg-white dark:bg-[#171717]">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <motion.div
              ref={howItWorksAnimation.ref}
              initial={{ opacity: 0, y: 20 }}
              animate={howItWorksAnimation.isVisible ? { opacity: 1, y: 0 } : { opacity: 0, y: 20 }}
              transition={{ duration: 0.2, ease: "easeOut" }}
            >
              <div className="text-center mb-16">
                <h2 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-6">
                  How It <span className="bg-gradient-to-r from-green-500 to-emerald-500 bg-clip-text text-transparent dark:from-green-400 dark:to-emerald-400">Works</span>
                </h2>
                <p className="text-xl text-gray-600 dark:text-gray-400 max-w-3xl mx-auto">
                  The complete carbon credit lifecycle on CBX
                </p>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
                <div className="text-center">
                  <div className="w-20 h-20 bg-green-500/20 rounded-2xl flex items-center justify-center mx-auto mb-6">
                    <ShoppingCart className="w-10 h-10 text-green-600 dark:text-green-400" />
                  </div>
                  <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-4">1. Browse & Buy</h3>
                  <p className="text-gray-600 dark:text-gray-400">
                    Explore verified carbon credit projects and purchase the exact amount you need
                  </p>
                </div>

                <div className="text-center">
                  <div className="w-20 h-20 bg-blue-500/20 rounded-2xl flex items-center justify-center mx-auto mb-6">
                    <Zap className="w-10 h-10 text-blue-600 dark:text-blue-400" />
                  </div>
                  <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-4">2. Instant Settlement</h3>
                  <p className="text-gray-600 dark:text-gray-400">
                    Credits are transferred to your wallet immediately upon payment
                  </p>
                </div>

                <div className="text-center">
                  <div className="w-20 h-20 bg-purple-500/20 rounded-2xl flex items-center justify-center mx-auto mb-6">
                    <Receipt className="w-10 h-10 text-purple-600 dark:text-purple-400" />
                  </div>
                  <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-4">3. Retire Credits</h3>
                  <p className="text-gray-600 dark:text-gray-400">
                    Permanently retire credits to offset your carbon footprint
                  </p>
                </div>

                <div className="text-center">
                  <div className="w-20 h-20 bg-orange-500/20 rounded-2xl flex items-center justify-center mx-auto mb-6">
                    <CheckCircle className="w-10 h-10 text-orange-600 dark:text-orange-400" />
                  </div>
                  <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-4">4. Get NFT Receipt</h3>
                  <p className="text-gray-600 dark:text-gray-400">
                    Receive an immutable NFT as proof of your environmental impact
                  </p>
                </div>
              </div>
            </motion.div>
          </div>
        </section>

        {/* Call to Action */}
        <section className="py-24 bg-white dark:bg-[#171717]">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <motion.div
              ref={ctaAnimation.ref}
              initial={{ opacity: 0, y: 20 }}
              animate={ctaAnimation.isVisible ? { opacity: 1, y: 0 } : { opacity: 0, y: 20 }}
              transition={{ duration: 0.2, ease: "easeOut" }}
              className="bg-gradient-to-r from-green-600 to-emerald-600 rounded-3xl p-12 text-white"
            >
              <h2 className="text-4xl md:text-5xl font-bold mb-6">
                Ready to Experience Web3 Carbon Credits?
              </h2>
              <p className="text-xl text-green-100 mb-8 max-w-2xl mx-auto">
                Join the future of carbon markets with transparent, efficient, and accessible on-chain trading.
              </p>
              <div className="flex flex-col sm:flex-row gap-6 justify-center">
                <Button 
                  asChild 
                  size="lg"
                  className="bg-white text-green-600 hover:bg-gray-100 shadow-lg"
                >
                  <a href="https://buy.cbx.earth" target="_blank" rel="noopener noreferrer">
                    <ShoppingCart className="w-5 h-5 mr-2" />
                    Start Trading
                  </a>
                </Button>
                <Button 
                  asChild 
                  size="lg"
                  variant="outline"
                  className="bg-white text-green-600 hover:bg-gray-100 shadow-lg"
                >
                  <a href="https://receipts.cbx.earth" target="_blank" rel="noopener noreferrer">
                    <Receipt className="w-5 h-5 mr-2" />
                    View Receipts
                  </a>
                </Button>
              </div>
            </motion.div>
          </div>
        </section>
      </div>
    </ThemeProvider>
  );
} 