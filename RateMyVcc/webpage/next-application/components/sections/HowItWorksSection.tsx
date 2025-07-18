'use client';

import { motion } from 'framer-motion';
import { ArrowRight } from 'lucide-react';

export function HowItWorksSection() {
  const steps = [
    {
      number: '1',
      title: 'Source Quality Credits',
      description: 'CBX purchases high-quality VCS Gold rated credits from Verra and pools them for maximum liquidity and transparency.',
    },
    {
      number: '2',
      title: 'Tokenize on Blockchain',
      description: 'Each credit becomes a CBX token on Etherlink L2, enabling fractional ownership, trading, and transparent tracking.',
    },
    {
      number: '3',
      title: 'Fractional Retirement',
      description: 'Our smart contract matches fractional tokens to form integer amounts for efficient retirement with Verra.',
    },
    {
      number: '4',
      title: 'Instant Settlement',
      description: 'On-chain settlement happens instantly with full transparency and immutable records on the blockchain.',
    },
    {
      number: '5',
      title: 'NFT Proof Receipt',
      description: 'Receive immutable NFT retirement receipts from Verra with your fractional amount recorded in the metadata.',
    },
  ];

  return (
    <section id="how-it-works" className="py-32" style={{ backgroundColor: '#171717' }}>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-start">
          {/* Left Side - Title and Description */}
          <motion.div
            initial={{ opacity: 0, x: -30 }}
            whileInView={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8 }}
            viewport={{ once: false }}
            className="lg:sticky lg:top-32"
          >
            <motion.h2
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0 }}
              viewport={{ once: false }}
              className="text-5xl md:text-6xl font-bold leading-tight mb-8"
            >
              <span className="bg-gradient-to-r from-green-400 to-emerald-400 bg-clip-text text-transparent">
                How it works?
              </span>
            </motion.h2>
            <motion.p
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
              viewport={{ once: false }}
              className="text-xl text-gray-400 leading-relaxed mb-8"
            >
              We revolutionize carbon credit markets through blockchain technology, 
              making fractional retirement accessible with full transparency and lower fees.
            </motion.p>
            
            {/* Decorative Arrow */}
            <div className="hidden lg:block mt-16">
              <svg 
                className="w-64 h-32" 
                viewBox="0 0 256 128" 
                fill="none"
              >
                <path
                  d="M20 100 Q 80 20, 200 60"
                  stroke="#10b981"
                  strokeWidth="2"
                  strokeDasharray="8 8"
                  fill="none"
                  className="opacity-60"
                />
                <path
                  d="M190 55 L200 60 L190 65"
                  stroke="#10b981"
                  strokeWidth="2"
                  fill="none"
                  className="opacity-60"
                />
              </svg>
            </div>
          </motion.div>

          {/* Right Side - Steps Timeline */}
          <motion.div
            initial={{ opacity: 0, x: 30 }}
            whileInView={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8 }}
            viewport={{ once: false }}
            className="relative"
          >
            {/* Vertical Line */}
            <div className="absolute left-6 top-6 bottom-6 w-0.5 bg-gray-700"></div>
            
            <div className="space-y-8">
              {steps.map((step, index) => (
                <motion.div
                  key={index}
                  initial={{ opacity: 0, y: 50 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  transition={{ 
                    duration: 0.6, 
                    delay: index === 0 ? 0 : index === 1 ? 0.2 : 0.4 + (index - 2) * 0.2 
                  }}
                  viewport={{ once: false }}
                  className="relative flex items-start space-x-6"
                >
                  {/* Step Number Circle */}
                  <div className="flex-shrink-0 relative z-10">
                    <div className="w-12 h-12 bg-gradient-to-r from-green-500 to-emerald-600 rounded-full flex items-center justify-center shadow-lg">
                      <span className="text-white font-bold text-lg">{step.number}</span>
                    </div>
                  </div>
                  
                  {/* Step Content */}
                  <div className="flex-1 pb-8">
                    <h3 className="text-2xl font-bold text-white mb-3">
                      {step.title}
                    </h3>
                    <p className="text-gray-400 leading-relaxed text-lg">
                      {step.description}
                    </p>
                  </div>
                </motion.div>
              ))}
            </div>
          </motion.div>
        </div>

        {/* Call to Action */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.5 }}
          viewport={{ once: false }}
          className="text-center mt-20"
        >
          <div className="bg-gray-800 border border-gray-700 rounded-2xl p-12 max-w-4xl mx-auto">
            <h4 className="text-3xl font-bold text-white mb-4">
              Ready to Experience the Future?
            </h4>
            <p className="text-xl text-gray-400 mb-8">
              Join thousands of people who already use CBX. Get transparent and efficient carbon offsetting.
            </p>
            
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-8">
              <div className="text-center">
                <div className="text-3xl font-bold text-green-400 mb-2">2-5%</div>
                <div className="text-gray-400">Lower Fees</div>
              </div>
              <div className="text-center">
                <div className="text-3xl font-bold text-blue-400 mb-2">NFT</div>
                <div className="text-gray-400">Proof Receipts</div>
              </div>
              <div className="text-center">
                <div className="text-3xl font-bold text-purple-400 mb-2">0.01+</div>
                <div className="text-gray-400">Min Tonnes</div>
              </div>
            </div>
            
            <button 
              onClick={() => document.getElementById('waitlist')?.scrollIntoView({ behavior: 'smooth' })}
              className="bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 text-white px-8 py-3 rounded-full font-semibold transition-all duration-300 hover:scale-105 flex items-center justify-center mx-auto"
            >
              Get Early Access
              <ArrowRight className="ml-2 w-5 h-5" />
            </button>
          </div>
        </motion.div>
      </div>
    </section>
  );
}