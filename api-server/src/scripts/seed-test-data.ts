/**
 * Comprehensive test data seed script for AssignX
 * Creates test data for all user types: user, doer, supervisor, admin
 * All accounts use admin@gmail.com pattern for dev bypass login
 *
 * Schema: Each role (User, Doer, Supervisor, Admin) has its own auth fields
 * directly -- no centralized Profile collection. Wallets are role-specific
 * (UserWallet, DoerWallet, SupervisorWallet).
 */
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.resolve(__dirname, '../../.env') });

// Import all models
import { User } from '../models/User';
import { Doer } from '../models/Doer';
import { Supervisor } from '../models/Supervisor';
import { Admin } from '../models/Admin';
import { UserWallet } from '../models/UserWallet';
import { DoerWallet } from '../models/DoerWallet';
import { SupervisorWallet } from '../models/SupervisorWallet';
import { WalletTransaction } from '../models/WalletTransaction';
import { Project } from '../models/Project';
import { ChatRoom } from '../models/ChatRoom';
import { ChatMessage } from '../models/ChatMessage';
import { Notification } from '../models/Notification';
import { SupportTicket } from '../models/SupportTicket';
import { CommunityPost } from '../models/CommunityPost';
import { Subject } from '../models/Subject';
import { Skill } from '../models/Skill';
import { ReferenceStyle } from '../models/ReferenceStyle';
import { Banner } from '../models/Banner';
import { TrainingModule } from '../models/TrainingModule';
import { FAQ } from '../models/FAQ';
import { DoerReview } from '../models/DoerReview';
import { DoerActivation } from '../models/DoerActivation';
import { QuizQuestion } from '../models/QuizQuestion';

const MONGODB_URI = process.env.MONGODB_URI || '';

async function seed() {
  console.log('Connecting to MongoDB...');
  await mongoose.connect(MONGODB_URI);
  console.log('Connected to MongoDB');

  // ============== STEP 1: Create Subjects, Skills, Reference Styles ==============
  console.log('\n--- Creating Subjects ---');
  const subjectNames = [
    { name: 'Computer Science', category: 'Engineering' },
    { name: 'Mathematics', category: 'Science' },
    { name: 'English Literature', category: 'Humanities' },
    { name: 'Business Management', category: 'Business' },
    { name: 'Psychology', category: 'Social Sciences' },
    { name: 'Economics', category: 'Business' },
    { name: 'Physics', category: 'Science' },
    { name: 'Marketing', category: 'Business' },
    { name: 'Data Science', category: 'Engineering' },
    { name: 'Mechanical Engineering', category: 'Engineering' },
  ];

  const subjects = [];
  for (const s of subjectNames) {
    const existing = await Subject.findOne({ name: s.name });
    if (existing) {
      subjects.push(existing);
    } else {
      subjects.push(await Subject.create(s));
    }
  }
  console.log(`Created/found ${subjects.length} subjects`);

  console.log('\n--- Creating Skills ---');
  const skillNames = [
    { name: 'Academic Writing', category: 'Writing' },
    { name: 'Research', category: 'Research' },
    { name: 'Data Analysis', category: 'Technical' },
    { name: 'Report Writing', category: 'Writing' },
    { name: 'Essay Writing', category: 'Writing' },
    { name: 'Proofreading', category: 'Editing' },
    { name: 'Thesis Writing', category: 'Writing' },
    { name: 'Programming', category: 'Technical' },
    { name: 'Statistics', category: 'Technical' },
    { name: 'Literature Review', category: 'Research' },
  ];

  const skills = [];
  for (const s of skillNames) {
    const existing = await Skill.findOne({ name: s.name });
    if (existing) {
      skills.push(existing);
    } else {
      skills.push(await Skill.create(s));
    }
  }
  console.log(`Created/found ${skills.length} skills`);

  console.log('\n--- Creating Reference Styles ---');
  const refStyles = [
    { name: 'APA 7th Edition', description: 'American Psychological Association, 7th edition' },
    { name: 'MLA 9th Edition', description: 'Modern Language Association, 9th edition' },
    { name: 'Chicago/Turabian', description: 'Chicago Manual of Style' },
    { name: 'Harvard', description: 'Harvard referencing style' },
    { name: 'IEEE', description: 'Institute of Electrical and Electronics Engineers' },
  ];

  const referenceStyles = [];
  for (const r of refStyles) {
    const existing = await ReferenceStyle.findOne({ name: r.name });
    if (existing) {
      referenceStyles.push(existing);
    } else {
      referenceStyles.push(await ReferenceStyle.create(r));
    }
  }
  console.log(`Created/found ${referenceStyles.length} reference styles`);

  // ============== STEP 2: Create Role Docs Directly ==============
  console.log('\n--- Creating Role Documents ---');

  // --- Admin ---
  let admin = await Admin.findOne({ email: 'admin@gmail.com' });
  if (!admin) {
    admin = await Admin.create({
      email: 'admin@gmail.com',
      fullName: 'Admin User',
      phone: '+91-9876543210',
      adminRole: 'super_admin',
      isActive: true,
      permissions: {
        manageUsers: true,
        manageProjects: true,
        manageWallets: true,
        manageBanners: true,
        viewAnalytics: true,
        manageSettings: true,
        manageModerations: true,
        manageSupport: true,
      },
      lastLoginAt: new Date(),
    });
  } else {
    admin.fullName = 'Admin User';
    admin.adminRole = 'super_admin';
    admin.isActive = true;
    await admin.save();
  }
  console.log(`Admin: ${admin._id} (${admin.email})`);

  // --- User (test student) ---
  let user = await User.findOne({ email: 'testuser@gmail.com' });
  if (!user) {
    user = await User.create({
      email: 'testuser@gmail.com',
      fullName: 'Test Student',
      phone: '+91-9876543211',
      userType: 'student',
      onboardingCompleted: true,
      lastLoginAt: new Date(),
      semester: 5,
      yearOfStudy: 3,
      studentIdNumber: 'STU-2024-001',
      expectedGraduationYear: 2027,
      collegeEmail: 'testuser@university.edu',
      collegeEmailVerified: true,
      preferredSubjects: [subjects[0]._id, subjects[1]._id, subjects[3]._id],
    });
  } else {
    user.fullName = 'Test Student';
    user.onboardingCompleted = true;
    await user.save();
  }
  console.log(`User: ${user._id} (${user.email})`);

  // --- Doer ---
  let doer = await Doer.findOne({ email: 'testdoer@gmail.com' });
  if (!doer) {
    doer = await Doer.create({
      email: 'testdoer@gmail.com',
      fullName: 'Test Doer',
      phone: '+91-9876543212',
      onboardingCompleted: true,
      lastLoginAt: new Date(),
      qualification: 'postgraduate',
      universityName: 'IIT Delhi',
      experienceLevel: 'pro',
      yearsOfExperience: 5,
      bio: 'Experienced academic writer specializing in Computer Science and Data Analysis. PhD candidate at IIT Delhi.',
      isAvailable: true,
      maxConcurrentProjects: 5,
      isActivated: true,
      activatedAt: new Date(Date.now() - 90 * 24 * 60 * 60 * 1000),
      totalEarnings: 125000,
      totalProjectsCompleted: 47,
      averageRating: 4.7,
      totalReviews: 38,
      successRate: 96,
      onTimeDeliveryRate: 94,
      bankDetails: {
        accountName: 'Test Doer',
        accountNumber: '1234567890123456',
        ifscCode: 'SBIN0001234',
        bankName: 'State Bank of India',
        upiId: 'testdoer@upi',
        verified: true,
      },
      skills: [
        { skillId: skills[0]._id, proficiencyLevel: 'expert', isVerified: true },
        { skillId: skills[1]._id, proficiencyLevel: 'expert', isVerified: true },
        { skillId: skills[2]._id, proficiencyLevel: 'advanced', isVerified: true },
        { skillId: skills[7]._id, proficiencyLevel: 'expert', isVerified: true },
      ],
      subjects: [
        { subjectId: subjects[0]._id, isPrimary: true },
        { subjectId: subjects[8]._id, isPrimary: false },
      ],
      isAccessGranted: true,
    });
  } else {
    doer.fullName = 'Test Doer';
    doer.onboardingCompleted = true;
    await doer.save();
  }
  console.log(`Doer: ${doer._id} (${doer.email})`);

  // --- Supervisor ---
  let supervisor = await Supervisor.findOne({ email: 'testsupervisor@gmail.com' });
  if (!supervisor) {
    supervisor = await Supervisor.create({
      email: 'testsupervisor@gmail.com',
      fullName: 'Test Supervisor',
      phone: '+91-9876543213',
      onboardingCompleted: true,
      lastLoginAt: new Date(),
      qualification: 'PhD in Computer Science',
      yearsOfExperience: 8,
      bio: 'Senior QA supervisor with 8 years of experience in academic quality assurance and project management.',
      isActive: true,
      isAccessGranted: true,
      totalEarnings: 85000,
      totalProjectsCompleted: 92,
      averageRating: 4.8,
      totalReviews: 75,
      bankDetails: {
        accountName: 'Test Supervisor',
        accountNumber: '9876543210987654',
        ifscCode: 'HDFC0001234',
        bankName: 'HDFC Bank',
        upiId: 'testsupervisor@upi',
        verified: true,
      },
    });
  } else {
    supervisor.fullName = 'Test Supervisor';
    supervisor.onboardingCompleted = true;
    await supervisor.save();
  }
  console.log(`Supervisor: ${supervisor._id} (${supervisor.email})`);

  // --- Additional real user ---
  let realUser = await User.findOne({ email: 'omrajpal.exe@gmail.com' });
  if (!realUser) {
    realUser = await User.create({
      email: 'omrajpal.exe@gmail.com',
      fullName: 'Om Rajpal',
      phone: '+91-9999888877',
      userType: 'student',
      onboardingCompleted: true,
      lastLoginAt: new Date(),
      semester: 6,
      yearOfStudy: 3,
      studentIdNumber: 'STU-2024-002',
      expectedGraduationYear: 2027,
      collegeEmail: 'omrajpal@university.edu',
      collegeEmailVerified: true,
      preferredSubjects: [subjects[0]._id, subjects[8]._id],
    });
  } else {
    realUser.fullName = 'Om Rajpal';
    realUser.onboardingCompleted = true;
    await realUser.save();
  }
  console.log(`Real User: ${realUser._id} (${realUser.email})`);

  // ============== STEP 3: Create Role-Specific Wallets ==============
  console.log('\n--- Creating Wallets ---');

  // User wallets
  const userWalletConfigs = [
    { userId: user._id, balance: 5000, totalCredited: 15000, totalDebited: 10000 },
    { userId: realUser._id, balance: 2500, totalCredited: 5000, totalDebited: 2500 },
  ];
  const userWallets: any[] = [];
  for (const wc of userWalletConfigs) {
    let wallet = await UserWallet.findOne({ userId: wc.userId });
    if (!wallet) {
      wallet = await UserWallet.create(wc);
    } else {
      Object.assign(wallet, wc);
      await wallet.save();
    }
    userWallets.push(wallet);
  }
  console.log(`Created/updated ${userWallets.length} user wallets`);

  // Doer wallet
  let doerWallet = await DoerWallet.findOne({ doerId: doer._id });
  if (!doerWallet) {
    doerWallet = await DoerWallet.create({
      doerId: doer._id,
      balance: 25000,
      totalCredited: 125000,
      totalDebited: 100000,
      totalWithdrawn: 80000,
    });
  } else {
    doerWallet.balance = 25000;
    doerWallet.totalCredited = 125000;
    doerWallet.totalDebited = 100000;
    doerWallet.totalWithdrawn = 80000;
    await doerWallet.save();
  }
  console.log(`Doer wallet: ${doerWallet._id}`);

  // Supervisor wallet
  let supervisorWallet = await SupervisorWallet.findOne({ supervisorId: supervisor._id });
  if (!supervisorWallet) {
    supervisorWallet = await SupervisorWallet.create({
      supervisorId: supervisor._id,
      balance: 15000,
      totalCredited: 85000,
      totalDebited: 70000,
      totalWithdrawn: 60000,
    });
  } else {
    supervisorWallet.balance = 15000;
    supervisorWallet.totalCredited = 85000;
    supervisorWallet.totalDebited = 70000;
    supervisorWallet.totalWithdrawn = 60000;
    await supervisorWallet.save();
  }
  console.log(`Supervisor wallet: ${supervisorWallet._id}`);

  // ============== STEP 4: Create Wallet Transactions ==============
  console.log('\n--- Creating Wallet Transactions ---');

  // User wallet transactions
  const userWallet = userWallets[0];
  const existingUserTxns = await WalletTransaction.countDocuments({ walletId: userWallet._id });
  if (existingUserTxns === 0) {
    await WalletTransaction.insertMany([
      { walletId: userWallet._id, walletType: 'user', transactionType: 'credit', amount: 5000, status: 'completed', description: 'Wallet top-up via Razorpay', referenceType: 'razorpay', balanceBefore: 0, balanceAfter: 5000, createdAt: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) },
      { walletId: userWallet._id, walletType: 'user', transactionType: 'debit', amount: 3000, status: 'completed', description: 'Payment for Project: CS Assignment Help', referenceType: 'project', balanceBefore: 5000, balanceAfter: 2000, createdAt: new Date(Date.now() - 25 * 24 * 60 * 60 * 1000) },
      { walletId: userWallet._id, walletType: 'user', transactionType: 'credit', amount: 10000, status: 'completed', description: 'Wallet top-up via Razorpay', referenceType: 'razorpay', balanceBefore: 2000, balanceAfter: 12000, createdAt: new Date(Date.now() - 20 * 24 * 60 * 60 * 1000) },
      { walletId: userWallet._id, walletType: 'user', transactionType: 'debit', amount: 4500, status: 'completed', description: 'Payment for Project: Data Analysis Report', referenceType: 'project', balanceBefore: 12000, balanceAfter: 7500, createdAt: new Date(Date.now() - 15 * 24 * 60 * 60 * 1000) },
      { walletId: userWallet._id, walletType: 'user', transactionType: 'debit', amount: 2500, status: 'completed', description: 'Payment for Project: Literature Review', referenceType: 'project', balanceBefore: 7500, balanceAfter: 5000, createdAt: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000) },
    ]);
  }

  // Doer wallet transactions
  const existingDoerTxns = await WalletTransaction.countDocuments({ walletId: doerWallet._id });
  if (existingDoerTxns === 0) {
    await WalletTransaction.insertMany([
      { walletId: doerWallet._id, walletType: 'doer', transactionType: 'credit', amount: 2100, status: 'completed', description: 'Earnings from Project: CS Assignment Help', referenceType: 'project', balanceBefore: 0, balanceAfter: 2100, createdAt: new Date(Date.now() - 24 * 24 * 60 * 60 * 1000) },
      { walletId: doerWallet._id, walletType: 'doer', transactionType: 'credit', amount: 3150, status: 'completed', description: 'Earnings from Project: Data Analysis Report', referenceType: 'project', balanceBefore: 2100, balanceAfter: 5250, createdAt: new Date(Date.now() - 14 * 24 * 60 * 60 * 1000) },
      { walletId: doerWallet._id, walletType: 'doer', transactionType: 'withdrawal', amount: 5000, status: 'completed', description: 'Bank withdrawal', referenceType: 'payout', balanceBefore: 30000, balanceAfter: 25000, createdAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) },
    ]);
  }

  // Supervisor wallet transactions
  const existingSvTxns = await WalletTransaction.countDocuments({ walletId: supervisorWallet._id });
  if (existingSvTxns === 0) {
    await WalletTransaction.insertMany([
      { walletId: supervisorWallet._id, walletType: 'supervisor', transactionType: 'credit', amount: 450, status: 'completed', description: 'Commission from Project: CS Assignment Help', referenceType: 'project', balanceBefore: 0, balanceAfter: 450, createdAt: new Date(Date.now() - 24 * 24 * 60 * 60 * 1000) },
      { walletId: supervisorWallet._id, walletType: 'supervisor', transactionType: 'credit', amount: 675, status: 'completed', description: 'Commission from Project: Data Analysis Report', referenceType: 'project', balanceBefore: 450, balanceAfter: 1125, createdAt: new Date(Date.now() - 14 * 24 * 60 * 60 * 1000) },
      { walletId: supervisorWallet._id, walletType: 'supervisor', transactionType: 'withdrawal', amount: 3000, status: 'completed', description: 'Bank withdrawal', referenceType: 'payout', balanceBefore: 18000, balanceAfter: 15000, createdAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000) },
    ]);
  }
  console.log('Wallet transactions created');

  // ============== STEP 5: Create Projects ==============
  console.log('\n--- Creating Projects ---');

  // Projects reference role doc _id directly: userId -> user._id, supervisorId -> supervisor._id, doerId -> doer._id
  const existingProjects = await Project.countDocuments({ userId: user._id });
  const projects: any[] = [];

  if (existingProjects === 0) {
    const projectData = [
      {
        projectNumber: 'PRJ-2026-001',
        userId: user._id,
        serviceType: 'assignment',
        title: 'Computer Science Data Structures Assignment',
        subjectId: subjects[0]._id,
        topic: 'Binary Trees and Graph Algorithms',
        description: 'Need help with a comprehensive assignment on binary trees, BST operations, and graph traversal algorithms including BFS and DFS with code examples.',
        wordCount: 3000,
        pageCount: 12,
        referenceStyleId: referenceStyles[4]._id,
        specificInstructions: 'Include working code examples in Python. Each algorithm should have time complexity analysis.',
        focusAreas: ['Binary Trees', 'Graph Algorithms', 'Time Complexity'],
        deadline: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000),
        originalDeadline: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000),
        status: 'in_progress',
        statusUpdatedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
        supervisorId: supervisor._id,
        doerId: doer._id,
        pricing: { userQuote: 3000, doerPayout: 2100, supervisorCommission: 450, platformFee: 450 },
        payment: { isPaid: true, paidAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000), paymentId: 'pay_test001' },
        delivery: { expectedDeliveryAt: new Date(Date.now() + 4 * 24 * 60 * 60 * 1000) },
        progressPercentage: 65,
        source: 'web',
      },
      {
        projectNumber: 'PRJ-2026-002',
        userId: user._id,
        serviceType: 'report',
        title: 'Data Analysis Report on Climate Change Trends',
        subjectId: subjects[8]._id,
        topic: 'Statistical Analysis of Global Temperature Data',
        description: 'Comprehensive data analysis report using R/Python on climate change trends. Includes regression analysis, hypothesis testing, and data visualization.',
        wordCount: 5000,
        pageCount: 20,
        referenceStyleId: referenceStyles[0]._id,
        specificInstructions: 'Use APA 7th edition. Include charts and graphs. Dataset will be provided.',
        focusAreas: ['Regression Analysis', 'Data Visualization', 'Hypothesis Testing'],
        deadline: new Date(Date.now() + 10 * 24 * 60 * 60 * 1000),
        originalDeadline: new Date(Date.now() + 10 * 24 * 60 * 60 * 1000),
        status: 'pending_assignment',
        statusUpdatedAt: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000),
        pricing: { userQuote: 4500, doerPayout: 3150, supervisorCommission: 675, platformFee: 675 },
        payment: { isPaid: true, paidAt: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000), paymentId: 'pay_test002' },
        progressPercentage: 0,
        source: 'web',
      },
      {
        projectNumber: 'PRJ-2026-003',
        userId: user._id,
        serviceType: 'essay',
        title: 'Literature Review: AI in Healthcare',
        subjectId: subjects[0]._id,
        topic: 'Applications of Artificial Intelligence in Medical Diagnosis',
        description: 'Literature review covering the latest research on AI applications in healthcare, focusing on diagnostic imaging and clinical decision support systems.',
        wordCount: 4000,
        pageCount: 16,
        referenceStyleId: referenceStyles[0]._id,
        specificInstructions: 'Include at least 30 peer-reviewed sources from the last 5 years.',
        focusAreas: ['Medical Imaging', 'Clinical Decision Support', 'Machine Learning'],
        deadline: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
        originalDeadline: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
        status: 'completed',
        statusUpdatedAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
        supervisorId: supervisor._id,
        doerId: doer._id,
        pricing: { userQuote: 2500, doerPayout: 1750, supervisorCommission: 375, platformFee: 375 },
        payment: { isPaid: true, paidAt: new Date(Date.now() - 20 * 24 * 60 * 60 * 1000), paymentId: 'pay_test003' },
        delivery: {
          deliveredAt: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000),
          expectedDeliveryAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
          completedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
        },
        qualityCheck: { aiScore: 92, plagiarismScore: 3 },
        progressPercentage: 100,
        userApproval: { approved: true, approvedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), feedback: 'Excellent work! Very thorough review.', grade: 'A' },
        source: 'web',
      },
      {
        projectNumber: 'PRJ-2026-004',
        userId: user._id,
        serviceType: 'proofreading',
        title: 'Business Management Case Study Proofread',
        subjectId: subjects[3]._id,
        topic: 'Strategic Management at Tesla Inc.',
        description: 'Proofread and edit a case study analysis of Tesla strategic management decisions.',
        wordCount: 2000,
        pageCount: 8,
        referenceStyleId: referenceStyles[3]._id,
        status: 'draft',
        statusUpdatedAt: new Date(),
        pricing: { userQuote: 800, doerPayout: 560, supervisorCommission: 120, platformFee: 120 },
        progressPercentage: 0,
        source: 'web',
      },
      {
        projectNumber: 'PRJ-2026-005',
        userId: user._id,
        serviceType: 'assignment',
        title: 'Mathematics: Linear Algebra Problem Set',
        subjectId: subjects[1]._id,
        topic: 'Eigenvalues, Eigenvectors, and Matrix Decomposition',
        description: 'Solve 15 problems on eigenvalues, eigenvectors, SVD, and matrix decomposition with detailed step-by-step solutions.',
        wordCount: 2500,
        pageCount: 10,
        referenceStyleId: referenceStyles[4]._id,
        specificInstructions: 'Show all work step by step. Use LaTeX formatting.',
        focusAreas: ['Eigenvalues', 'SVD', 'Matrix Decomposition'],
        deadline: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000),
        originalDeadline: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000),
        status: 'under_review',
        statusUpdatedAt: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000),
        supervisorId: supervisor._id,
        doerId: doer._id,
        pricing: { userQuote: 2000, doerPayout: 1400, supervisorCommission: 300, platformFee: 300 },
        payment: { isPaid: true, paidAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), paymentId: 'pay_test005' },
        delivery: {
          deliveredAt: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000),
          expectedDeliveryAt: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000),
        },
        qualityCheck: { aiScore: 88, plagiarismScore: 1 },
        progressPercentage: 100,
        source: 'web',
      },
      {
        projectNumber: 'PRJ-2026-006',
        userId: realUser._id,
        serviceType: 'assignment',
        title: 'Psychology Research Paper',
        subjectId: subjects[4]._id,
        topic: 'Cognitive Behavioral Therapy Effectiveness',
        description: 'Research paper on the effectiveness of CBT for anxiety disorders, including meta-analysis of recent studies.',
        wordCount: 6000,
        pageCount: 24,
        referenceStyleId: referenceStyles[0]._id,
        deadline: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000),
        status: 'in_progress',
        supervisorId: supervisor._id,
        doerId: doer._id,
        pricing: { userQuote: 5000, doerPayout: 3500, supervisorCommission: 750, platformFee: 750 },
        payment: { isPaid: true, paidAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), paymentId: 'pay_test006' },
        delivery: { expectedDeliveryAt: new Date(Date.now() + 12 * 24 * 60 * 60 * 1000) },
        progressPercentage: 30,
        source: 'web',
      },
    ];

    for (const pd of projectData) {
      const p = await Project.create(pd);
      projects.push(p);
    }
    console.log(`Created ${projects.length} projects`);
  } else {
    const existingP = await Project.find({ userId: { $in: [user._id, realUser._id] } });
    projects.push(...existingP);
    console.log(`Found ${projects.length} existing projects`);
  }

  // ============== STEP 6: Create Chat Rooms & Messages ==============
  console.log('\n--- Creating Chat Rooms & Messages ---');

  if (projects.length > 0) {
    const project1 = projects[0];
    let chatRoom = await ChatRoom.findOne({ projectId: project1._id });
    if (!chatRoom) {
      chatRoom = await ChatRoom.create({
        projectId: project1._id,
        roomType: 'project_all',
        name: `Chat: ${project1.title}`,
        participants: [
          { id: user._id, role: 'user', joinedAt: new Date(), isActive: true },
          { id: supervisor._id, role: 'supervisor', joinedAt: new Date(), isActive: true },
          { id: doer._id, role: 'doer', joinedAt: new Date(), isActive: true },
        ],
        lastMessageAt: new Date(),
      });

      // Create messages with senderRole field
      await ChatMessage.insertMany([
        { chatRoomId: chatRoom._id, senderId: user._id, senderRole: 'user', messageType: 'text', content: 'Hi! I have submitted my project requirements. Please let me know if you need any clarification.', readBy: [{ id: user._id, role: 'user' }, { id: supervisor._id, role: 'supervisor' }], createdAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000) },
        { chatRoomId: chatRoom._id, senderId: supervisor._id, senderRole: 'supervisor', messageType: 'text', content: 'Hello! I have reviewed your requirements. Everything looks clear. I have assigned this to our best doer for CS assignments.', readBy: [{ id: user._id, role: 'user' }, { id: supervisor._id, role: 'supervisor' }, { id: doer._id, role: 'doer' }], createdAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000 + 3600000) },
        { chatRoomId: chatRoom._id, senderId: doer._id, senderRole: 'doer', messageType: 'text', content: 'Hi there! I am working on your assignment. The Binary Trees section is complete. Currently working on Graph Algorithms.', readBy: [{ id: doer._id, role: 'doer' }, { id: supervisor._id, role: 'supervisor' }], createdAt: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000) },
        { chatRoomId: chatRoom._id, senderId: user._id, senderRole: 'user', messageType: 'text', content: 'Great progress! For the BFS/DFS section, can you also include an example with an adjacency matrix representation?', readBy: [{ id: user._id, role: 'user' }], createdAt: new Date(Date.now() - 12 * 60 * 60 * 1000) },
        { chatRoomId: chatRoom._id, senderId: doer._id, senderRole: 'doer', messageType: 'text', content: 'Sure, I will include both adjacency list and matrix representations. Expected to finish by tomorrow.', readBy: [{ id: doer._id, role: 'doer' }], createdAt: new Date(Date.now() - 6 * 60 * 60 * 1000) },
      ]);
      console.log('Created chat room and messages for project 1');
    }
  }

  // ============== STEP 7: Create Notifications ==============
  console.log('\n--- Creating Notifications ---');

  const existingNotifs = await Notification.countDocuments({ recipientId: user._id, recipientRole: 'user' });
  if (existingNotifs === 0) {
    // User notifications
    await Notification.insertMany([
      { recipientId: user._id, recipientRole: 'user', type: 'project_update', title: 'Project Update', message: 'Your project "CS Data Structures Assignment" is now 65% complete.', data: { projectId: projects[0]?._id }, isRead: false, createdAt: new Date(Date.now() - 2 * 60 * 60 * 1000) },
      { recipientId: user._id, recipientRole: 'user', type: 'payment_received', title: 'Payment Confirmed', message: 'Payment of Rs 3,000 for "CS Data Structures Assignment" has been confirmed.', data: {}, isRead: true, createdAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000), readAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000 + 3600000) },
      { recipientId: user._id, recipientRole: 'user', type: 'project_completed', title: 'Project Completed', message: 'Your project "AI in Healthcare Literature Review" has been completed and delivered!', data: { projectId: projects[2]?._id }, isRead: true, createdAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), readAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000 + 1800000) },
      { recipientId: user._id, recipientRole: 'user', type: 'new_message', title: 'New Message', message: 'You have a new message from your doer on "CS Data Structures Assignment"', data: {}, isRead: false, createdAt: new Date(Date.now() - 6 * 60 * 60 * 1000) },
      { recipientId: user._id, recipientRole: 'user', type: 'system', title: 'Welcome to AssignX!', message: 'Welcome to AssignX. Start by creating your first project or browsing our expert services.', data: {}, isRead: true, createdAt: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), readAt: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000 + 600000) },
    ]);

    // Doer notifications
    await Notification.insertMany([
      { recipientId: doer._id, recipientRole: 'doer', type: 'project_assigned', title: 'New Project Assigned', message: 'You have been assigned to "CS Data Structures Assignment".', data: { projectId: projects[0]?._id }, isRead: true, createdAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000) },
      { recipientId: doer._id, recipientRole: 'doer', type: 'earnings', title: 'Earnings Received', message: 'You earned Rs 1,750 for completing "AI in Healthcare Literature Review".', data: {}, isRead: false, createdAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000) },
      { recipientId: doer._id, recipientRole: 'doer', type: 'deadline_reminder', title: 'Deadline Approaching', message: 'Project "CS Data Structures Assignment" deadline is in 5 days.', data: { projectId: projects[0]?._id }, isRead: false, createdAt: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000) },
    ]);

    // Supervisor notifications
    await Notification.insertMany([
      { recipientId: supervisor._id, recipientRole: 'supervisor', type: 'project_assigned', title: 'New Project to Supervise', message: 'You have been assigned to supervise "CS Data Structures Assignment".', data: { projectId: projects[0]?._id }, isRead: true, createdAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000) },
      { recipientId: supervisor._id, recipientRole: 'supervisor', type: 'review_needed', title: 'Review Needed', message: 'Project "Linear Algebra Problem Set" is ready for your review.', data: { projectId: projects[4]?._id }, isRead: false, createdAt: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000) },
    ]);
  }
  console.log('Notifications created');

  // ============== STEP 8: Create Support Tickets ==============
  console.log('\n--- Creating Support Tickets ---');

  const existingTickets = await SupportTicket.countDocuments({ raisedById: user._id });
  if (existingTickets === 0) {
    await SupportTicket.insertMany([
      {
        raisedById: user._id,
        raisedByRole: 'user',
        userName: 'Test Student',
        subject: 'Payment not reflecting in wallet',
        description: 'I made a payment of Rs 5000 via Razorpay but it is not showing in my wallet balance.',
        category: 'billing',
        priority: 'high',
        status: 'in_progress',
        messages: [
          { senderId: user._id, senderName: 'Test Student', senderRole: 'user', message: 'I made a payment 2 hours ago but it still shows pending.', createdAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000) },
          { senderId: admin._id, senderName: 'Admin User', senderRole: 'admin', message: 'We are looking into this issue. Can you please share your Razorpay transaction ID?', createdAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000 + 7200000) },
          { senderId: user._id, senderName: 'Test Student', senderRole: 'user', message: 'The transaction ID is pay_test_abc123.', createdAt: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000) },
        ],
      },
      {
        raisedById: user._id,
        raisedByRole: 'user',
        userName: 'Test Student',
        subject: 'How to extend project deadline?',
        description: 'I need to extend the deadline for my current project. How can I do this?',
        category: 'general',
        priority: 'medium',
        status: 'resolved',
        resolvedAt: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000),
        messages: [
          { senderId: user._id, senderName: 'Test Student', senderRole: 'user', message: 'Can I extend my project deadline?', createdAt: new Date(Date.now() - 12 * 24 * 60 * 60 * 1000) },
          { senderId: admin._id, senderName: 'Admin User', senderRole: 'admin', message: 'Yes, you can request a deadline extension from the project details page. Click on "Request Extension" button.', createdAt: new Date(Date.now() - 11 * 24 * 60 * 60 * 1000) },
        ],
      },
      {
        raisedById: doer._id,
        raisedByRole: 'doer',
        userName: 'Test Doer',
        subject: 'Withdrawal to bank account delayed',
        description: 'My bank withdrawal request from 7 days ago is still showing as pending.',
        category: 'billing',
        priority: 'high',
        status: 'open',
        messages: [
          { senderId: doer._id, senderName: 'Test Doer', senderRole: 'doer', message: 'My withdrawal has been pending for 7 days now. Please help.', createdAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000) },
        ],
      },
    ]);
  }
  console.log('Support tickets created');

  // ============== STEP 9: Create Community Posts ==============
  console.log('\n--- Creating Community Posts ---');

  const existingPosts = await CommunityPost.countDocuments({ userId: user._id });
  if (existingPosts === 0) {
    await CommunityPost.insertMany([
      {
        userId: user._id,
        postType: 'campus',
        title: 'Best resources for Data Structures?',
        content: 'Can anyone recommend good resources for learning Data Structures and Algorithms? I am in my 3rd year CS and preparing for placements.',
        category: 'academic',
        tags: ['DSA', 'Placements', 'CS'],
        viewCount: 156,
        likeCount: 23,
        commentCount: 8,
        comments: [
          { userId: realUser._id, content: 'I recommend Striver\'s A2Z DSA sheet. It covers everything!', likeCount: 5, createdAt: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000) },
        ],
        createdAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
      },
      {
        userId: realUser._id,
        postType: 'campus',
        title: 'Study group for Machine Learning exam',
        content: 'Looking for people to form a study group for the upcoming ML exam. We can meet at the library on weekends.',
        category: 'study_group',
        tags: ['ML', 'Study Group', 'Exam Prep'],
        viewCount: 89,
        likeCount: 12,
        commentCount: 3,
        comments: [
          { userId: user._id, content: 'Count me in! What time works for everyone?', likeCount: 2, createdAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000) },
        ],
        createdAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
      },
      {
        userId: user._id,
        postType: 'pro_network',
        title: 'Freelance Web Developer Available',
        content: 'Hi! I am a full-stack web developer with experience in React, Node.js, and MongoDB. Available for freelance projects.',
        category: 'freelance',
        tags: ['Web Development', 'Freelance', 'React'],
        viewCount: 245,
        likeCount: 34,
        commentCount: 5,
        createdAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
      },
      {
        userId: realUser._id,
        postType: 'business_hub',
        title: 'Looking for co-founder for EdTech startup',
        content: 'Building an EdTech platform to help students with personalized learning. Looking for a technical co-founder with AI/ML experience.',
        category: 'startup',
        tags: ['EdTech', 'Startup', 'Co-founder'],
        viewCount: 320,
        likeCount: 45,
        commentCount: 12,
        createdAt: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000),
      },
    ]);
  }
  console.log('Community posts created');

  // ============== STEP 10: Create Banners ==============
  console.log('\n--- Creating Banners ---');

  const existingBanners = await Banner.countDocuments();
  if (existingBanners === 0) {
    await Banner.insertMany([
      { title: 'New Semester Offer', description: 'Get 20% off on your first project this semester!', imageUrl: 'https://placehold.co/1200x400/2563EB/white?text=20%+Off+First+Project', linkUrl: '/projects', target: 'user', isActive: true, order: 1, startDate: new Date(), endDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) },
      { title: 'Become a Top Doer', description: 'Complete 10 projects to earn the Top Doer badge and higher earnings!', imageUrl: 'https://placehold.co/1200x400/059669/white?text=Top+Doer+Badge', linkUrl: '/dashboard', target: 'doer', isActive: true, order: 2 },
      { title: 'Quality Assurance Week', description: 'Supervisors: Enhanced QC tools available. Earn bonus commissions this week!', imageUrl: 'https://placehold.co/1200x400/7C3AED/white?text=QA+Week+Bonus', linkUrl: '/projects', target: 'supervisor', isActive: true, order: 3 },
    ]);
  }
  console.log('Banners created');

  // ============== STEP 11: Create Training Modules ==============
  console.log('\n--- Creating Training Modules ---');

  const existingTraining = await TrainingModule.countDocuments();
  if (existingTraining === 0) {
    await TrainingModule.insertMany([
      { title: 'Getting Started as a Doer', description: 'Learn the basics of the AssignX platform and how to complete your first project successfully.', videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', thumbnailUrl: 'https://placehold.co/640x360/2563EB/white?text=Getting+Started', duration: 600, category: 'onboarding', targetRole: 'doer', order: 1 },
      { title: 'Academic Writing Standards', description: 'Master academic writing standards including citation formats, proper structure, and quality guidelines.', videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', thumbnailUrl: 'https://placehold.co/640x360/059669/white?text=Writing+Standards', duration: 900, category: 'skills', targetRole: 'doer', order: 2 },
      { title: 'Quality Check Process', description: 'Understanding the QC process, plagiarism checking, and delivering high-quality work.', videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', thumbnailUrl: 'https://placehold.co/640x360/7C3AED/white?text=QC+Process', duration: 720, category: 'quality', targetRole: 'doer', order: 3 },
      { title: 'Supervisor Onboarding', description: 'Learn how to review projects, communicate with doers, and ensure quality standards.', videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', thumbnailUrl: 'https://placehold.co/640x360/DC2626/white?text=Supervisor+Guide', duration: 480, category: 'onboarding', targetRole: 'supervisor', order: 1 },
      { title: 'Effective Project Management', description: 'Tips for managing multiple projects, meeting deadlines, and maintaining communication.', videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', thumbnailUrl: 'https://placehold.co/640x360/EA580C/white?text=Project+Management', duration: 540, category: 'management', targetRole: 'supervisor', order: 2 },
    ]);
  }
  console.log('Training modules created');

  // ============== STEP 12: Create FAQs ==============
  console.log('\n--- Creating FAQs ---');

  const existingFAQs = await FAQ.countDocuments();
  if (existingFAQs === 0) {
    await FAQ.insertMany([
      { question: 'How do I submit a new project?', answer: 'Go to the Projects page and click "New Project". Fill in the required details including subject, topic, word count, and deadline. Then proceed to payment to confirm your order.', category: 'projects', isActive: true, order: 1 },
      { question: 'What payment methods are accepted?', answer: 'We accept payments via Razorpay including UPI, credit/debit cards, net banking, and wallet payments. You can also use your AssignX wallet balance.', category: 'payments', isActive: true, order: 2 },
      { question: 'How long does it take to complete a project?', answer: 'Delivery time depends on the project complexity and word count. Typically, projects are delivered 1-2 days before the deadline. You can track progress in real-time from the project details page.', category: 'projects', isActive: true, order: 3 },
      { question: 'Can I request revisions?', answer: 'Yes, you can request up to 2 free revisions within 7 days of delivery. Additional revisions may incur extra charges. Use the revision request form on the project page.', category: 'projects', isActive: true, order: 4 },
      { question: 'How do I withdraw my earnings?', answer: 'Go to Wallet > Withdraw. Enter the amount and confirm. Withdrawals are processed to your registered bank account within 3-5 business days.', category: 'payments', isActive: true, order: 5 },
    ]);
  }
  console.log('FAQs created');

  // ============== STEP 13: Create Doer Reviews ==============
  console.log('\n--- Creating Doer Reviews ---');

  const existingReviews = await DoerReview.countDocuments({ doerId: doer._id });
  if (existingReviews === 0) {
    await DoerReview.insertMany([
      { doerId: doer._id, reviewerId: user._id, projectId: projects[2]?._id, rating: 5, review: 'Excellent work on the literature review. Very thorough and well-structured. Highly recommended!', createdAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000) },
      { doerId: doer._id, reviewerId: supervisor._id, projectId: projects[2]?._id, rating: 4, review: 'Good quality work. Met all the requirements and delivered on time.', createdAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000) },
      { doerId: doer._id, reviewerId: realUser._id, rating: 5, review: 'Great doer! Completed my assignment perfectly and ahead of schedule.', createdAt: new Date(Date.now() - 15 * 24 * 60 * 60 * 1000) },
    ]);
  }
  console.log('Doer reviews created');

  // ============== STEP 14: Create Quiz Questions (for doer/supervisor activation) ==============
  console.log('\n--- Creating Quiz Questions ---');

  const trainingModules = await TrainingModule.find({});
  const doerModule = trainingModules.find(m => m.targetRole === 'doer') || trainingModules[0];
  const supervisorModule = trainingModules.find(m => m.targetRole === 'supervisor') || trainingModules[0];

  const existingQuizQ = await QuizQuestion.countDocuments();
  if (existingQuizQ === 0 && doerModule) {
    await QuizQuestion.insertMany([
      { moduleId: doerModule._id, question: 'What is the correct citation format for APA 7th edition?', options: ['Author, Year, Title', '(Author, Year)', 'Author (Year). Title.', 'Title - Author - Year'], correctAnswer: 2, isActive: true },
      { moduleId: doerModule._id, question: 'What is considered plagiarism?', options: ['Paraphrasing with citation', 'Direct copy without attribution', 'Summarizing a source', 'Using your own ideas'], correctAnswer: 1, isActive: true },
      { moduleId: doerModule._id, question: 'The maximum allowed plagiarism score for delivery is:', options: ['5%', '10%', '15%', '20%'], correctAnswer: 1, isActive: true },
      { moduleId: supervisorModule?._id || doerModule._id, question: 'When should a supervisor escalate a quality issue?', options: ['Never', 'When plagiarism > 10%', 'Only when user complains', 'After 3 failed reviews'], correctAnswer: 1, isActive: true },
    ]);
  }
  console.log('Quiz questions created');

  // ============== DONE ==============
  console.log('\n===== SEED COMPLETE =====');
  console.log('\nTest accounts:');
  console.log('  Admin:      admin@gmail.com           (dev bypass - no OTP needed)');
  console.log('  User:       testuser@gmail.com        (dev login - any OTP in dev mode)');
  console.log('  Doer:       testdoer@gmail.com        (dev login - any OTP in dev mode)');
  console.log('  Supervisor: testsupervisor@gmail.com   (dev login - any OTP in dev mode)');
  console.log('  Real User:  omrajpal.exe@gmail.com     (OTP / dev login)');
  console.log('\nRole Doc IDs:');
  console.log(`  Admin:      ${admin._id}`);
  console.log(`  User:       ${user._id}`);
  console.log(`  Doer:       ${doer._id}`);
  console.log(`  Supervisor: ${supervisor._id}`);
  console.log(`  Real User:  ${realUser._id}`);

  await mongoose.disconnect();
  console.log('\nDisconnected from MongoDB');
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
