'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Search, TrendingUp, AlertCircle, Loader2, Zap, Shield, Award } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';

export default function App() {
  return <RateMyVCCSection />;
}

export function RateMyVCCSection() {
  const [searchTerm, setSearchTerm] = useState('');
  const [searchResults, setSearchResults] = useState<any[]>([]);
  const [isSearching, setIsSearching] = useState(false);
  const [hasSearched, setHasSearched] = useState(false);

  const mockCredits = [
    {
      id: 'VCS-001',
      name: 'Katingan Mentaya Peatland Restoration',
      methodology: 'REDD+',
      score: 88,
      country: 'Indonesia',
      vintage: '2023',
      priceRange: '$12-15',
      risk: 'Low',
      region: 'Asia',
      projectType: 'Afforestation/Reforestation',
      status: 'Active'
    },
    {
      id: 'VCS-002',
      name: 'Solar Farm Development',
      methodology: 'Renewable Energy',
      score: 76,
      country: 'India',
      vintage: '2022',
      priceRange: '$8-12',
      risk: 'Medium',
      region: 'Asia',
      projectType: 'Renewable Energy',
      status: 'Active'
    },
    {
      id: 'VCS-003',
      name: 'Mangrove Restoration',
      methodology: 'Blue Carbon',
      score: 94,
      country: 'Philippines',
      vintage: '2023',
      priceRange: '$18-22',
      risk: 'Very Low',
      region: 'Asia',
      projectType: 'Blue Carbon',
      status: 'Active'
    },
  ];

  const handleSearch = async () => {
    if (!searchTerm.trim()) return;

    setIsSearching(true);
    setHasSearched(true);

    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 2000));

    // Filter results based on search term
    const filteredResults = mockCredits.filter(credit =>
      credit.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      credit.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
      credit.methodology.toLowerCase().includes(searchTerm.toLowerCase())
    );

    setSearchResults(filteredResults);
    setIsSearching(false);
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      handleSearch();
    }
  };

  const getScoreColor = (score: number) => {
    if (score >= 90) return 'text-emerald-400';
    if (score >= 75) return 'text-yellow-400';
    if (score >= 60) return 'text-orange-400';
    return 'text-red-400';
  };

  const getScoreGradient = (score: number) => {
    if (score >= 90) return 'from-emerald-500 to-green-400';
    if (score >= 75) return 'from-yellow-500 to-amber-400';
    if (score >= 60) return 'from-orange-500 to-yellow-400';
    return 'from-red-500 to-orange-400';
  };

  const getRiskColor = (risk: string) => {
    switch (risk) {
      case 'Very Low': return 'text-emerald-400 bg-emerald-500/10 border-emerald-500/20';
      case 'Low': return 'text-green-400 bg-green-500/10 border-green-500/20';
      case 'Medium': return 'text-yellow-400 bg-yellow-500/10 border-yellow-500/20';
      case 'High': return 'text-orange-400 bg-orange-500/10 border-orange-500/20';
      default: return 'text-gray-400 bg-gray-500/10 border-gray-500/20';
    }
  };

  return (
    <section id="rate-credits" className="py-20 md:py-32 relative overflow-hidden font-sans bg-white dark:bg-[#171717]">
      {/* Background Grid */}
      <div className="absolute inset-0 opacity-[0.03]">
        <div className="absolute inset-0" style={{
          backgroundImage: `
            linear-gradient(rgba(0,0,0,0.1) 1px, transparent 1px),
            linear-gradient(90deg, rgba(0,0,0,0.1) 1px, transparent 1px)
          `,
          backgroundSize: '50px 50px'
        }} />
      </div>

      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 relative">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          viewport={{ once: false }}
          className="text-center mb-12 md:mb-16"
        >
          <h2 className="text-4xl md:text-6xl font-bold text-gray-900 dark:text-white mb-4 md:mb-6">
            Introducing{' '}
            <span className="bg-gradient-to-r from-green-400 to-emerald-400 bg-clip-text text-transparent">
              RateMyVCC
            </span>
          </h2>

          <motion.p
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.15, delay: 0.1 }}
            viewport={{ once: false }}
            className="text-lg md:text-xl text-gray-600 dark:text-gray-400 max-w-3xl mx-auto leading-relaxed"
          >
            Want to check a carbon credit's quality? Enter any Verra Registry ID below. 
            You'll get an instant score from 1-100. Our system checks the project's 
            methodology, additionality, and permanence for you.
          </motion.p>
        </motion.div>

        {/* Search Interface */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.15, delay: 0.15 }}
          viewport={{ once: false }}
          className="mb-12 md:mb-16"
        >
          <div className="max-w-4xl mx-auto">
            {/* Search Bar and Button on Same Line */}
            <div className="flex flex-col md:flex-row gap-4 items-stretch">
              {/* Search Input */}
              <div className="flex-1 relative">
                <Search className="absolute left-6 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-500 dark:text-gray-500" />
                <input
                  type="text"
                  placeholder="Try 'VCS-1396' or 'Katingan Peatland'"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  onKeyPress={handleKeyPress}
                  className="w-full pl-14 pr-6 py-4 bg-white dark:bg-[#232323] border border-gray-300 dark:border-gray-600 rounded-xl text-gray-900 dark:text-white placeholder-gray-500 focus:border-green-500 focus:outline-none text-lg"
                />
              </div>
              
              {/* Rate Button */}
              <Button
                onClick={handleSearch}
                disabled={isSearching || !searchTerm.trim()}
                className="bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 text-white px-8 py-4 rounded-xl font-semibold transition-all duration-300 hover:scale-105 disabled:opacity-50 disabled:hover:scale-100 text-lg flex items-center justify-center whitespace-nowrap h-[60px]"
              >
                {isSearching ? (
                  <Loader2 className="w-5 h-5 animate-spin mr-2" />
                ) : (
                  <Zap className="w-5 h-5 mr-2" />
                )}
                {isSearching ? 'Checking Quality...' : 'Get Quality Score'}
              </Button>
            </div>
          </div>
        </motion.div>

        {/* Loading State */}
        <AnimatePresence>
          {isSearching && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              transition={{ duration: 0.6 }}
              className="text-center py-12"
            >
              <Loader2 className="w-8 h-8 text-green-400 animate-spin mx-auto mb-4" />
              <h3 className="text-xl font-semibold text-white mb-2">Checking Credit Quality</h3>
              <p className="text-gray-400">Analyzing project data and verification standards...</p>
            </motion.div>
          )}
        </AnimatePresence>

        {/* Results */}
        <AnimatePresence>
          {!isSearching && searchResults.length > 0 && (
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -30 }}
              transition={{ duration: 0.6 }}
              className="max-w-4xl mx-auto"
            >
              {searchResults.slice(0, 1).map((credit, index) => (
                <motion.div
                  key={credit.id}
                  initial={{ opacity: 0, y: 30, scale: 0.95 }}
                  animate={{ opacity: 1, y: 0, scale: 1 }}
                  transition={{ duration: 0.15, delay: index * 0.02 }}
                >
                  <Card className="bg-gray-800/80 backdrop-blur-sm border border-gray-700 hover:border-gray-600 transition-all duration-300 group overflow-hidden rounded-2xl">
                    <div className="absolute inset-0 bg-gradient-to-br from-green-500/5 to-emerald-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-300" />

                    <CardContent className="p-6 md:p-10 relative">
                      {/* Header Section */}
                      <div className="flex flex-col md:flex-row items-start justify-between mb-8">
                        <div className="flex-1 pr-0 md:pr-8 mb-6 md:mb-0">
                          <div className="flex items-center flex-wrap gap-2 mb-4">
                            <span className="text-sm font-mono text-blue-400 bg-blue-500/10 px-3 py-1.5 rounded-lg border border-blue-500/20">
                              {credit.id}
                            </span>
                            <span className={`text-sm px-3 py-1.5 rounded-lg border font-medium ${getRiskColor(credit.risk)}`}>
                              {credit.risk} Risk
                            </span>
                            <span className="text-sm px-3 py-1.5 rounded-lg border border-green-500/20 text-green-400 bg-green-500/10">
                              Active
                            </span>
                          </div>
                          <h3 className="text-2xl font-bold text-gray-900 dark:text-white mb-2 leading-tight">
                            {credit.name}
                          </h3>
                          <p className="text-lg text-gray-400 mb-3">{credit.methodology}</p>
                          <p className="text-gray-500 text-sm">
                            {credit.country} • {credit.region} • Vintage {credit.vintage}
                          </p>
                        </div>

                        {/* Animated Score Circle */}
                        <div className="relative flex-shrink-0 mx-auto md:mx-0">
                          <motion.div
                            initial={{ scale: 0, rotate: -180 }}
                            animate={{ scale: 1, rotate: 0 }}
                            transition={{ duration: 0.2, delay: 0.1, type: "spring", stiffness: 200 }}
                            className={`w-32 h-32 rounded-full bg-gradient-to-br ${getScoreGradient(credit.score)} p-1 shadow-lg`}
                          >
                            <div className="w-full h-full bg-gray-800 rounded-full flex items-center justify-center relative overflow-hidden">
                              <motion.div
                                animate={{ scale: [1, 1.2, 1], opacity: [0.3, 0.1, 0.3] }}
                                transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
                                className={`absolute inset-0 rounded-full bg-gradient-to-br ${getScoreGradient(credit.score)} opacity-20`}
                              />
                              <div className="text-center">
                                <motion.div
                                  initial={{ opacity: 0 }}
                                  animate={{ opacity: 1 }}
                                  transition={{ duration: 0.15, delay: 0.2 }}
                                  className={`text-4xl font-bold ${getScoreColor(credit.score)}`}
                                >
                                  <motion.span
                                    initial={{ opacity: 0 }}
                                    animate={{ opacity: 1 }}
                                    transition={{ duration: 0.15, delay: 0.25 }}
                                  >
                                    {credit.score}
                                  </motion.span>
                                </motion.div>
                                <div className="text-sm text-gray-500 dark:text-gray-500 font-medium">/ 100</div>
                              </div>
                            </div>
                          </motion.div>
                        </div>
                      </div>

                      {/* Detailed Information Grid */}
                      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 md:gap-6 mb-8">
                        <div className="bg-gray-700 rounded-xl p-4 border border-gray-600">
                          <div className="text-xs text-gray-400 mb-1">Project Type</div>
                          <div className="text-base text-white font-semibold">{credit.projectType}</div>
                        </div>
                        <div className="bg-gray-700 rounded-xl p-4 border border-gray-600">
                          <div className="text-xs text-gray-400 mb-1">Price Range</div>
                          <div className="text-base text-white font-semibold">{credit.priceRange}</div>
                        </div>
                        <div className="bg-gray-700 rounded-xl p-4 border border-gray-600">
                          <div className="text-xs text-gray-400 mb-1">Methodology</div>
                          <div className="text-base text-white font-semibold">{credit.methodology}</div>
                        </div>
                      </div>

                      {/* Quality Breakdown */}
                      <div className="mb-8">
                        <div className="space-y-3">
                          {/* Additionality */}
                          <div className="flex items-center justify-between">
                            <span className="text-gray-400 text-sm">Additionality</span>
                            <div className="flex items-center space-x-2">
                              <div className="w-24 h-2 bg-gray-700 rounded-full overflow-hidden">
                                <motion.div
                                  initial={{ width: 0 }}
                                  animate={{ width: '85%' }}
                                  transition={{ duration: 0.15, delay: 0.3, ease: "easeOut" }}
                                  className="h-full bg-gradient-to-r from-green-500 to-emerald-400"
                                />
                              </div>
                              <span className="text-white font-medium text-sm w-6 text-right">85</span>
                            </div>
                          </div>
                          {/* Permanence */}
                          <div className="flex items-center justify-between">
                            <span className="text-gray-400 text-sm">Permanence</span>
                            <div className="flex items-center space-x-2">
                              <div className="w-24 h-2 bg-gray-700 rounded-full overflow-hidden">
                                <motion.div
                                  initial={{ width: 0 }}
                                  animate={{ width: '92%' }}
                                  transition={{ duration: 0.15, delay: 0.35, ease: "easeOut" }}
                                  className="h-full bg-gradient-to-r from-green-500 to-emerald-400"
                                />
                              </div>
                              <span className="text-white font-medium text-sm w-6 text-right">92</span>
                            </div>
                          </div>
                          {/* Verification */}
                          <div className="flex items-center justify-between">
                            <span className="text-gray-400 text-sm">Verification</span>
                            <div className="flex items-center space-x-2">
                              <div className="w-24 h-2 bg-gray-700 rounded-full overflow-hidden">
                                <motion.div
                                  initial={{ width: 0 }}
                                  animate={{ width: '88%' }}
                                  transition={{ duration: 0.15, delay: 0.4, ease: "easeOut" }}
                                  className="h-full bg-gradient-to-r from-green-500 to-emerald-400"
                                />
                              </div>
                              <span className="text-white font-medium text-sm w-6 text-right">88</span>
                            </div>
                          </div>
                        </div>
                      </div>

                      {/* Action Buttons */}
                      <div className="flex justify-center">
                        <Button className="flex-1 bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 text-white font-semibold py-3 rounded-xl transition-all duration-200 hover:scale-105 flex items-center justify-center">
                          <Award className="w-5 h-5 mr-2" />
                          View Full Report
                        </Button>
                      </div>
                    </CardContent>
                  </Card>
                </motion.div>
              ))}
            </motion.div>
          )}
        </AnimatePresence>

        {/* No Results */}
        <AnimatePresence>
          {!isSearching && hasSearched && searchResults.length === 0 && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              transition={{ duration: 0.6 }}
              className="text-center py-16"
            >
              <div className="w-16 h-16 bg-gray-800 rounded-full flex items-center justify-center mx-auto mb-4">
                <AlertCircle className="w-8 h-8 text-gray-500" />
              </div>
              <h3 className="text-xl font-semibold text-white mb-2">Credit Not Found</h3>
              <p className="text-gray-400 mb-6">Double-check the VCS ID or try a different project name.</p>
              <Button
                onClick={() => { setHasSearched(false); setSearchTerm(''); }}
                variant="outline"
                className="border-gray-600 text-gray-300 hover:bg-gray-700 hover:text-white px-6 py-2 rounded-lg"
              >
                Try Again
              </Button>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </section>
  );
}