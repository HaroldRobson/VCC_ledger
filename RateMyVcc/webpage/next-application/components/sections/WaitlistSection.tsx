'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { Mail, CheckCircle, ArrowRight } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useAnimateOnce } from '../../hooks/useOneDirectionalAnimation';

export function WaitlistSection() {
  const [email, setEmail] = useState('');
  const [isSubmitted, setIsSubmitted] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  
  const mainAnimation = useAnimateOnce<HTMLDivElement>();
  const titleAnimation = useAnimateOnce<HTMLHeadingElement>();
  const descriptionAnimation = useAnimateOnce<HTMLParagraphElement>();
  const formAnimation = useAnimateOnce<HTMLFormElement>();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email.trim()) return;

    setIsLoading(true);
    
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1500));
    
    setIsSubmitted(true);
    setIsLoading(false);
    setEmail('');
  };

  return (
    <section id="waitlist" className="py-24 bg-white dark:bg-[#171717]">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        {!isSubmitted ? (
          <motion.div
            ref={mainAnimation.ref}
            initial={{ opacity: 0, y: 20 }}
            animate={mainAnimation.isVisible ? { opacity: 1, y: 0 } : { opacity: 0, y: 20 }}
            transition={{ duration: 0.2, ease: "easeOut" }}
          >
            <motion.h2
              ref={titleAnimation.ref}
              initial={{ opacity: 0, y: 20 }}
              animate={titleAnimation.isVisible ? { opacity: 1, y: 0 } : { opacity: 0, y: 20 }}
              transition={{ duration: 0.2, delay: 0.1, ease: "easeOut" }}
              className="text-5xl md:text-6xl font-bold text-gray-900 dark:text-white mb-6"
            >
              Join the Waitlist
            </motion.h2>
            
            <motion.p
              ref={descriptionAnimation.ref}
              initial={{ opacity: 0, y: 20 }}
              animate={descriptionAnimation.isVisible ? { opacity: 1, y: 0 } : { opacity: 0, y: 20 }}
              transition={{ duration: 0.2, delay: 0.15, ease: "easeOut" }}
              className="text-xl text-gray-600 dark:text-gray-400 mb-12 max-w-2xl mx-auto"
            >
              Be among the first to experience the future of carbon credits.
            </motion.p>

            <motion.form
              ref={formAnimation.ref}
              initial={{ opacity: 0, y: 20 }}
              animate={formAnimation.isVisible ? { opacity: 1, y: 0 } : { opacity: 0, y: 20 }}
              transition={{ duration: 0.2, delay: 0.2, ease: "easeOut" }}
              onSubmit={handleSubmit}
              className="max-w-4xl mx-auto"
            >
              <div className="flex flex-col md:flex-row gap-4 items-stretch">
                <div className="flex-1 relative">
                  <input
                    type="email"
                    placeholder="Enter your email address"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                    className="w-full pl-6 pr-6 py-4 bg-white dark:bg-[#232323] border border-gray-300 dark:border-gray-600 rounded-xl text-gray-900 dark:text-white placeholder-gray-500 focus:border-green-500 focus:outline-none text-lg"
                  />
                </div>
                <Button
                  type="submit"
                  disabled={isLoading || !email.trim()}
                  className="bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 text-white px-8 py-4 rounded-xl font-semibold transition-all duration-300 hover:scale-105 disabled:opacity-50 disabled:hover:scale-100 text-lg flex items-center justify-center whitespace-nowrap h-[60px]"
                >
                  {isLoading ? (
                    <motion.div
                      animate={{ rotate: 360 }}
                      transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
                    >
                      <ArrowRight className="w-5 h-5" />
                    </motion.div>
                  ) : (
                    <>
                      <span>Join Waitlist</span>
                      <ArrowRight className="ml-2 w-5 h-5" />
                    </>
                  )}
                </Button>
              </div>
            </motion.form>
          </motion.div>
        ) : (
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.3, ease: "easeOut" }}
          >
            <div className="w-16 h-16 bg-green-500/20 border border-green-500/30 rounded-full flex items-center justify-center mx-auto mb-8">
              <CheckCircle className="w-8 h-8 text-green-400" />
            </div>
            
            <h3 className="text-3xl font-bold text-white mb-4">
              Welcome to CBX Early Access!
            </h3>
            
            <p className="text-lg text-gray-600 dark:text-gray-400 mb-8">
              We'll email you first when CBX launches. Get ready for lower fees and transparent carbon credits.
            </p>

            <Button
              onClick={() => setIsSubmitted(false)}
              variant="outline"
              className="border-gray-600 text-gray-300 hover:bg-gray-700 hover:text-white"
            >
              Invite a Colleague
            </Button>
          </motion.div>
        )}
      </div>
    </section>
  );
}