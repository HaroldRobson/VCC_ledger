'use client';

import React, { useState, useEffect, useRef } from 'react';
import { motion } from 'framer-motion';

export default function App() {
  return <ProblemSolutionSection />;
}

// Custom hook to detect when an element is in the viewport
const useInView = (options) => {
  const ref = useRef(null);
  const [isInView, setIsInView] = useState(false);

  useEffect(() => {
    const observer = new IntersectionObserver(([entry]) => {
      // Update state based on whether element is in view.
      // This will make the animation re-trigger every time.
      setIsInView(entry.isIntersecting);
    }, options);

    const currentRef = ref.current;
    if (currentRef) {
      observer.observe(currentRef);
    }

    return () => {
      if (currentRef) {
        observer.unobserve(currentRef);
      }
    };
  }, [ref, options]);

  return [ref, isInView];
};


// A helper component for consistent row styling and height
const ComparisonRow = ({ children, className = '' }) => (
  <div className={`h-16 flex items-center ${className}`}>{children}</div>
);

// A new component to wrap each row and apply the animation
const AnimatedRow = ({ children, index }) => {
  const [ref, isInView] = useInView({ threshold: 0.1 });

  const style = {
    transition: 'all 0.6s ease-out',
    transitionDelay: `${index * 0.1}s`,
    opacity: isInView ? 1 : 0,
    transform: isInView ? 'translateY(0)' : 'translateY(20px)',
  };

  return (
    <div ref={ref} style={style} key={isInView ? 'visible' : 'hidden'}>
      {children}
    </div>
  );
};


export function ProblemSolutionSection() {
  const comparisons = [
    {
      feature: 'Transaction Fees',
      cbx: '2-5% total fees',
      traditional: '20-40% broker fees',
    },
    {
      feature: 'Retirement Proof',
      cbx: 'NFT Receipt from Verra',
      traditional: 'No proof provided',
    },
    {
      feature: 'Quality Transparency',
      cbx: 'AI-powered 1-100 rating system',
      traditional: 'No quality scoring available',
    },
    {
      feature: 'Minimum Purchase',
      cbx: '0.01 tonnes fractional retirement',
      traditional: '1+ tonnes minimum order',
    },
    {
      feature: 'Settlement Time',
      cbx: 'Instant on-chain settlement',
      traditional: '2-5 business days processing',
    },
    {
      feature: 'Verification Method',
      cbx: 'Blockchain immutable records',
      traditional: 'Paper certificates only',
    },
  ];

  return (
    <section className="py-24" style={{ backgroundColor: '#171717' }}>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0 }}
          viewport={{ once: false }}
        >
            <div className="text-center mb-20">
            <h2 className="text-6xl md:text-7xl font-bold text-white mb-6">
                Why{' '}
                <span className="bg-gradient-to-r from-green-400 to-emerald-400 bg-clip-text text-transparent">
                CBX
                </span>
            </h2>
            </div>
        </motion.div>

        {/* Main Comparison Table Container */}
        <div className="max-w-7xl mx-auto">
          <div className="grid grid-cols-3 items-start gap-x-8">
            
            {/* Column 1: Feature Labels (Left Aligned and shifted right) */}
            <div className="text-left pl-4">
              <motion.div
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: 0.2 }}
                viewport={{ once: false }}
                className="h-32"
              ></motion.div> {/* Spacer to align with headers */}
              <div className="space-y-2">
                {comparisons.map((comparison, index) => (
                  <motion.div
                    key={comparison.feature}
                    initial={{ opacity: 0, y: 30 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.6, delay: 0.4 + (index * 0.1) }}
                    viewport={{ once: false }}
                  >
                    <ComparisonRow className="justify-start">
                      <span className="text-gray-300 font-medium text-lg">
                        {comparison.feature}
                      </span>
                    </ComparisonRow>
                  </motion.div>
                ))}
              </div>
            </div>

            {/* Column 2: CBX (Single Card) */}
            <div className="bg-gradient-to-b from-green-600 to-emerald-800 rounded-2xl shadow-2xl shadow-green-500/20">
              <motion.div
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: 0.2 }}
                viewport={{ once: false }}
              >
                <div className="h-32 flex items-center justify-center">
                  <h3 className="text-white font-bold text-5xl">CBX</h3>
                </div>
              </motion.div>
              <div className="space-y-2 px-10 pb-6">
                {comparisons.map((comparison, index) => (
                   <motion.div
                    key={comparison.cbx}
                    initial={{ opacity: 0, y: 30 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.6, delay: 0.4 + (index * 0.1) }}
                    viewport={{ once: false }}
                  >
                    <ComparisonRow className="justify-start">
                      <div className="flex items-center space-x-3">
                        <svg className="w-6 h-6 text-white flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                          <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                        </svg>
                        <span className="text-white font-medium text-base">
                          {comparison.cbx}
                        </span>
                      </div>
                    </ComparisonRow>
                  </motion.div>
                ))}
              </div>
            </div>

            {/* Column 3: Traditional Brokers (Left Aligned) */}
            <div className="text-left">
              <motion.div
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: 0.2 }}
                viewport={{ once: false }}
              >
                <div className="h-32 flex items-center">
                   <h4 className="text-emerald-400 text-2xl lg:text-3xl font-semibold">Traditional Brokers</h4>
                </div>
              </motion.div>
              <div className="space-y-2">
                {comparisons.map((comparison, index) => (
                   <motion.div
                    key={comparison.traditional}
                    initial={{ opacity: 0, y: 30 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.6, delay: 0.4 + (index * 0.1) }}
                    viewport={{ once: false }}
                  >
                    <ComparisonRow className="justify-start">
                      <div className="flex items-center space-x-3">
                        <svg className="w-6 h-6 text-red-400 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                          <path fillRule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clipRule="evenodd" />
                        </svg>
                        <span className="text-gray-400 text-base">
                          {comparison.traditional}
                        </span>
                      </div>
                    </ComparisonRow>
                  </motion.div>
                ))}
              </div>
            </div>

          </div>

          {/* Call to Action Button */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 1.0 }}
            viewport={{ once: false }}
            className="text-center mt-20"
          >
            <button
              onClick={() => document.getElementById('waitlist')?.scrollIntoView({ behavior: 'smooth' })}
              className="bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 text-white px-10 py-4 rounded-full font-semibold text-lg transition-all duration-300 hover:scale-105 transform flex items-center justify-center mx-auto"
            >
              Start Saving on Fees
              <svg className="ml-3 w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
              </svg>
            </button>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
