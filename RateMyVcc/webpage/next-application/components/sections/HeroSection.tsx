'use client';

import React from 'react';
import { motion } from 'framer-motion';
import { ChevronDown, ArrowRight, Leaf } from 'lucide-react';
import { Button } from '@/components/ui/button';

export function HeroSection() {
  const scrollToNext = () => {
    const nextSection = document.getElementById('rate-credits');
    nextSection?.scrollIntoView({ behavior: 'smooth' });
  };

  const scrollToWaitlist = () => {
    const waitlistSection = document.getElementById('waitlist');
    waitlistSection?.scrollIntoView({ behavior: 'smooth' });
  };

  return (
      <section id="home" className="bg-background">
        {/* Background Elements - Correctly Layered */}
        <div className="absolute inset-0">
          {/* 1. Subtle grid pattern (Bottom layer) */}
          <div
            className="absolute inset-0 bg-repeat opacity-[0.02]"
            style={{
              backgroundImage: `
                linear-gradient(rgba(0,0,0,0.1) 1px, transparent 1px),
                linear-gradient(90deg, rgba(0,0,0,0.1) 1px, transparent 1px)
              `,
              backgroundSize: '100px 100px'
            }}
          />
          
          {/* 2. Dark gradient overlay (Middle layer) */}
          {/* <div className="absolute inset-0 z-[1] bg-gradient-to-br from-gray-50/95 via-gray-100/90 to-gray-50/95 dark:from-gray-900/95 dark:via-gray-900/90 dark:to-gray-900/95" /> */}
           <div className="absolute inset-0 z-[1]" style={{ background: 'linear-gradient(135deg, rgba(23,23,23,0.95) 0%, rgba(23,23,23,0.90) 50%, rgba(23,23,23,0.95) 100%)' }} />

          {/* 3. STATIC graphics (Top background layer, above gradient) */}
          <div className="absolute inset-0 z-[2] overflow-hidden">
            <svg className="absolute w-full h-full" viewBox="0 0 1600 900" preserveAspectRatio="xMidYMid slice">
              {/* Path 1: Left - MOVED SLIGHTLY HIGHER */}
              <path
                d="M 50 100 C 300 250, 250 460, 550 510"
                fill="none"
                stroke="currentColor"
                className="text-green-500"
                strokeWidth="2"
                strokeDasharray="4 14"
                strokeLinecap="round"
              />
              {/* Icon 1: Positioned at the new end of the path */}
              <g transform="translate(569, 518) rotate(80) scale(1.7)">
                <path d="M17 8C8 10 5.9 16.17 3.82 21.34l1.89.66.95-2.3C7.14 19.87 7.64 20 8 20c11 0 14-17 14-17-1 2-8 2.25-13 3.25S2 11.5 2 13.5c0 2 1.75 3.75 1.75 3.75C7 8 17 8 17 8z" fill="currentColor" className="text-green-500" transform="translate(-12, -12)" />
              </g>

              {/* Path 2: Right - REDRAWN to curve up from bottom right */}
              <path
                d="M 1600 900 C 700 450, 1300 500, 1050 600"
                fill="none"
                stroke="currentColor"
                className="text-green-500"
                strokeWidth="2"
                strokeDasharray="4 14"
                strokeLinecap="round"
              />
              {/* Icon 2: Positioned at the new end of the path */}
              <g transform="translate(1020, 610) rotate(-145) scale(1.7)">
                 <path d="M17 8C8 10 5.9 16.17 3.82 21.34l1.89.66.95-2.3C7.14 19.87 7.64 20 8 20c11 0 14-17 14-17-1 2-8 2.25-13 3.25S2 11.5 2 13.5c0 2 1.75 3.75 1.75 3.75C7 8 17 8 17 8z" fill="currentColor" className="text-green-500" transform="translate(-12, -12)" />
              </g>
            </svg>
          </div>
        </div>

        {/* Content - Sits on top of all background elements */}
        <div className="relative z-10 min-h-screen flex items-center justify-center px-4 pt-16">
          <div className="max-w-4xl mx-auto text-center">
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.2 }}
              className="mb-8"
            >
              <span className="inline-flex items-center px-4 py-2 bg-green-500/10 text-green-400 rounded-full text-sm font-medium border border-green-500/20">
                <Leaf className="w-4 h-4 mr-2" />
                Powered by Etherlink L2
              </span>
            </motion.div>

            <motion.h1
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.4 }}
              className="text-5xl md:text-7xl font-bold text-gray-900 dark:text-white mb-8 leading-tight"
            >
              The Future of Carbon Credits is{' '}
              <span className="bg-gradient-to-r from-green-500 to-emerald-500 bg-clip-text text-transparent dark:from-green-400 dark:to-emerald-400">
                Here
              </span>
            </motion.h1>

            <motion.p
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.6 }}
              className="text-xl md:text-2xl text-gray-600 dark:text-gray-300 mb-12 max-w-3xl mx-auto leading-relaxed"
            >
              Retire carbon credits in any amount you want. Get blockchain verification 
              and NFT receipts. Pay lower fees than traditional brokers.
            </motion.p>

            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.8 }}
              className="flex flex-col sm:flex-row gap-6 justify-center items-center mb-16"
            >
              <Button
                onClick={scrollToWaitlist}
                size="lg"
                className="bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 text-white px-10 py-4 text-lg rounded-full transition-all duration-300 hover:scale-105 shadow-lg hover:shadow-green-500/25 inline-flex items-center"
              >
                Get Early Access
                <ArrowRight className="ml-2 w-5 h-5" />
              </Button>
              <Button
                onClick={scrollToNext}
                variant="outline"
                size="lg"
                className="border-2 border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 hover:text-gray-900 dark:hover:text-white px-10 py-4 text-lg rounded-full transition-all duration-300 hover:scale-105 bg-white dark:bg-transparent"
              >
                See How It Works
              </Button>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 1.0 }}
              className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-3xl mx-auto"
            >
              <div className="text-center p-6 bg-white/80 dark:bg-gray-800/30 backdrop-blur-sm rounded-2xl border border-gray-200/50 dark:border-gray-700/50">
                <div className="text-3xl font-bold text-green-400 mb-2">20-40%</div>
                <div className="text-gray-600 dark:text-gray-400 text-sm">Lower fees than brokers</div>
              </div>
              <div className="text-center p-6 bg-white/80 dark:bg-gray-800/30 backdrop-blur-sm rounded-2xl border border-gray-200/50 dark:border-gray-700/50">
                <div className="text-3xl font-bold text-green-400 mb-2">100%</div>
                <div className="text-gray-600 dark:text-gray-400 text-sm">Transparent quality</div>
              </div>
              <div className="text-center p-6 bg-white/80 dark:bg-gray-800/30 backdrop-blur-sm rounded-2xl border border-gray-200/50 dark:border-gray-700/50">
                <div className="text-3xl font-bold text-green-400 mb-2">NFT</div>
                <div className="text-gray-600 dark:text-gray-400 text-sm">Retirement receipts</div>
              </div>
            </motion.div>
          </div>
        </div>

        {/* Scroll Indicator */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 1, delay: 1.2 }}
          className="absolute bottom-8 left-1/2 transform -translate-x-1/2 cursor-pointer z-10"
          onClick={scrollToNext}
        >
          <motion.div
            animate={{ y: [0, 10, 0] }}
            transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
            className="flex flex-col items-center text-gray-500 dark:text-gray-400"
          >
            <span className="text-sm mb-2">Scroll to explore</span>
            <div className="w-8 h-8 border border-green-400/30 rounded-full flex items-center justify-center">
              <ChevronDown className="w-4 h-4" />
            </div>
          </motion.div>
        </motion.div>
      </section>

  );
}