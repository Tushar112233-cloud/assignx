/**
 * Seed comprehensive test data for supervisor jasvintaneja2307@gmail.com
 */
const mongoose = require('mongoose');

const MONGODB_URI = 'mongodb+srv://omrajpal:1122334455@cluster0.tva2yqz.mongodb.net/AssignX?retryWrites=true&w=majority&appName=Cluster0';

async function seed() {
  await mongoose.connect(MONGODB_URI);
  const db = mongoose.connection.db;
  const email = 'jasvintaneja2307@gmail.com';
  const now = Date.now();
  const DAY = 86400000;

  // 1. Get supervisor
  const supervisor = await db.collection('supervisors').findOne({ email });
  if (!supervisor) { console.log('ERROR: No supervisor found for', email); process.exit(1); }
  console.log('Supervisor:', supervisor._id, supervisor.fullName);

  // 2. Get subjects & ref styles
  const subjects = await db.collection('subjects').find({}).toArray();
  const refStyles = await db.collection('referencestyles').find({}).toArray();
  console.log('Subjects:', subjects.length, '| RefStyles:', refStyles.length);

  const csSubject = subjects.find(s => s.slug === 'computer-science');
  const dsSubject = subjects.find(s => s.slug === 'data-science');
  const engSubject = subjects.find(s => s.slug === 'engineering');
  const bizSubject = subjects.find(s => s.slug === 'business');
  const econSubject = subjects.find(s => s.slug === 'economics');
  const apa = refStyles.find(r => r.name && r.name.includes('APA'));
  const ieee = refStyles.find(r => r.name && r.name.includes('IEEE'));
  const harvard = refStyles.find(r => r.name && r.name.includes('Harvard'));

  // 3. Update supervisor profile
  await db.collection('supervisors').updateOne({ _id: supervisor._id }, { $set: {
    isActive: true,
    isActivated: true,
    isApproved: true,
    isAccessGranted: true,
    onboardingCompleted: true,
    totalEarnings: 67500,
    totalProjectsCompleted: 38,
    averageRating: 4.6,
    totalReviews: 30,
    onTimeDeliveryRate: 92,
    successRate: 95,
    subjects: [
      csSubject && { subjectId: csSubject._id, isPrimary: true },
      engSubject && { subjectId: engSubject._id, isPrimary: false },
      dsSubject && { subjectId: dsSubject._id, isPrimary: false },
    ].filter(Boolean),
  }});
  console.log('Updated supervisor profile');

  // 4. Create clients
  async function ensureUser(userEmail, fullName, phone, userType) {
    let user = await db.collection('users').findOne({ email: userEmail });
    if (!user) {
      const r = await db.collection('users').insertOne({
        email: userEmail, fullName, phone, userType,
        onboardingCompleted: true, refreshTokens: [], createdAt: new Date(),
      });
      return { _id: r.insertedId, fullName };
    }
    return { _id: user._id, fullName: user.fullName || fullName };
  }

  const client1 = await ensureUser('rahul.sharma.test@gmail.com', 'Rahul Sharma', '+91-9876500001', 'student');
  const client2 = await ensureUser('priya.patel.test@gmail.com', 'Priya Patel', '+91-9876500002', 'professional');
  const client3 = await ensureUser('amit.kumar.test@gmail.com', 'Amit Kumar', '+91-9876500003', 'student');
  console.log('Clients ready');

  // 5. Create doers
  async function ensureDoer(doerEmail, data) {
    let doer = await db.collection('doers').findOne({ email: doerEmail });
    if (!doer) {
      const r = await db.collection('doers').insertOne({
        email: doerEmail, ...data,
        isAvailable: true, isActivated: true, isAccessGranted: true,
        onboardingCompleted: true, refreshTokens: [], createdAt: new Date(),
      });
      return { _id: r.insertedId, fullName: data.fullName };
    }
    return { _id: doer._id, fullName: doer.fullName || data.fullName };
  }

  const doer1 = await ensureDoer('doer.ananya.test@gmail.com', {
    fullName: 'Ananya Gupta', phone: '+91-9876600001',
    qualification: 'postgraduate', universityName: 'IIT Bombay',
    experienceLevel: 'pro', yearsOfExperience: 4,
    bio: 'Expert in Computer Science and Data Analysis',
    activatedAt: new Date(now - 120*DAY),
    totalEarnings: 95000, totalProjectsCompleted: 35,
    averageRating: 4.8, totalReviews: 28, successRate: 97, onTimeDeliveryRate: 96,
    bankDetails: { accountName: 'Ananya Gupta', accountNumber: '1111222233334444', ifscCode: 'SBIN0001111', bankName: 'SBI', upiId: 'ananya@upi', verified: true },
  });
  const doer2 = await ensureDoer('doer.vikram.test@gmail.com', {
    fullName: 'Vikram Singh', phone: '+91-9876600002',
    qualification: 'phd', universityName: 'IISc Bangalore',
    experienceLevel: 'pro', yearsOfExperience: 6,
    bio: 'PhD researcher in Machine Learning and Statistics',
    activatedAt: new Date(now - 200*DAY),
    totalEarnings: 142000, totalProjectsCompleted: 52,
    averageRating: 4.9, totalReviews: 45, successRate: 98, onTimeDeliveryRate: 95,
    bankDetails: { accountName: 'Vikram Singh', accountNumber: '5555666677778888', ifscCode: 'HDFC0002222', bankName: 'HDFC Bank', upiId: 'vikram@upi', verified: true },
  });
  const doer3 = await ensureDoer('doer.sneha.test@gmail.com', {
    fullName: 'Sneha Reddy', phone: '+91-9876600003',
    qualification: 'postgraduate', universityName: 'NIT Trichy',
    experienceLevel: 'intermediate', yearsOfExperience: 2,
    bio: 'Specializing in Business Management and Economics',
    activatedAt: new Date(now - 60*DAY),
    totalEarnings: 45000, totalProjectsCompleted: 18,
    averageRating: 4.5, totalReviews: 14, successRate: 94, onTimeDeliveryRate: 89,
    bankDetails: { accountName: 'Sneha Reddy', accountNumber: '9999000011112222', ifscCode: 'ICIC0003333', bankName: 'ICICI Bank', upiId: 'sneha@upi', verified: true },
  });
  console.log('Doers ready');

  // 6. Create projects
  const projectData = [
    // NEW REQUESTS (submitted)
    {
      projectNumber: 'AX-10001', userId: client1._id, serviceType: 'assignment',
      title: 'Machine Learning Classification Project',
      subjectId: csSubject && csSubject._id, topic: 'SVM and Random Forest Classifiers',
      description: 'Implement and compare SVM vs Random Forest for text classification. Include accuracy metrics, confusion matrix, and ROC curves.',
      wordCount: 4000, pageCount: 16, referenceStyleId: ieee && ieee._id,
      specificInstructions: 'Use Python with sklearn. Provide Jupyter notebook.',
      focusAreas: ['SVM', 'Random Forest', 'Text Classification'],
      deadline: new Date(now + 7*DAY), originalDeadline: new Date(now + 7*DAY),
      status: 'submitted', statusUpdatedAt: new Date(now - 2*3600000),
      supervisorId: supervisor._id,
      pricing: {}, payment: { isPaid: false },
      progressPercentage: 0, source: 'web', clientName: 'Rahul Sharma',
      createdAt: new Date(now - 2*3600000),
    },
    {
      projectNumber: 'AX-10002', userId: client2._id, serviceType: 'report',
      title: 'Market Research: EV Industry Analysis',
      subjectId: bizSubject && bizSubject._id, topic: 'Electric Vehicle Market Trends in India 2025-2030',
      description: 'Comprehensive market research report on EV industry in India with competitor analysis, SWOT, and market size projections.',
      wordCount: 6000, pageCount: 24, referenceStyleId: apa && apa._id,
      focusAreas: ['Market Size', 'Competitor Analysis', 'Growth Projections'],
      deadline: new Date(now + 12*DAY), originalDeadline: new Date(now + 12*DAY),
      status: 'submitted', statusUpdatedAt: new Date(now - 5*3600000),
      supervisorId: supervisor._id,
      pricing: {}, payment: { isPaid: false },
      progressPercentage: 0, source: 'app', clientName: 'Priya Patel',
      createdAt: new Date(now - 5*3600000),
    },
    {
      projectNumber: 'AX-10003', userId: client3._id, serviceType: 'essay',
      title: 'Impact of AI on Employment',
      subjectId: econSubject && econSubject._id, topic: 'Artificial Intelligence and Future of Jobs',
      description: 'Argumentative essay on how AI will reshape the job market. Discuss both displacement and creation of new roles.',
      wordCount: 3000, pageCount: 12, referenceStyleId: harvard && harvard._id,
      deadline: new Date(now + 5*DAY), originalDeadline: new Date(now + 5*DAY),
      status: 'submitted', statusUpdatedAt: new Date(now - 1*3600000),
      supervisorId: supervisor._id,
      pricing: {}, payment: { isPaid: false },
      progressPercentage: 0, source: 'web', clientName: 'Amit Kumar',
      createdAt: new Date(now - 1*3600000),
    },

    // PAID - READY TO ASSIGN
    {
      projectNumber: 'AX-10004', userId: client1._id, serviceType: 'assignment',
      title: 'Database Systems: Query Optimization',
      subjectId: csSubject && csSubject._id, topic: 'SQL Query Optimization and Indexing Strategies',
      description: 'Assignment on SQL query optimization techniques including B-tree indexes, query plans, and normalization.',
      wordCount: 3500, pageCount: 14, referenceStyleId: ieee && ieee._id,
      specificInstructions: 'Use PostgreSQL examples.',
      focusAreas: ['Indexing', 'Query Plans', 'Normalization'],
      deadline: new Date(now + 6*DAY), originalDeadline: new Date(now + 6*DAY),
      status: 'paid', statusUpdatedAt: new Date(now - 1*DAY),
      supervisorId: supervisor._id,
      pricing: { userQuote: 3500, finalQuote: 3500, doerPayout: 2450, supervisorCommission: 525, platformFee: 525 },
      payment: { isPaid: true, paidAt: new Date(now - 1*DAY), paymentId: 'pay_jt001' },
      progressPercentage: 0, source: 'web', clientName: 'Rahul Sharma',
      createdAt: new Date(now - 2*DAY),
    },
    {
      projectNumber: 'AX-10005', userId: client2._id, serviceType: 'report',
      title: 'Statistical Analysis of Consumer Behavior',
      subjectId: dsSubject && dsSubject._id, topic: 'Consumer Purchase Patterns During Festive Season',
      description: 'Data analysis report using survey data on consumer behavior during Diwali season with regression and cluster analysis.',
      wordCount: 5000, pageCount: 20, referenceStyleId: apa && apa._id,
      focusAreas: ['Regression', 'Clustering', 'Survey Analysis'],
      deadline: new Date(now + 8*DAY), originalDeadline: new Date(now + 8*DAY),
      status: 'paid', statusUpdatedAt: new Date(now - 12*3600000),
      supervisorId: supervisor._id,
      pricing: { userQuote: 4500, finalQuote: 4500, doerPayout: 3150, supervisorCommission: 675, platformFee: 675 },
      payment: { isPaid: true, paidAt: new Date(now - 12*3600000), paymentId: 'pay_jt002' },
      progressPercentage: 0, source: 'app', clientName: 'Priya Patel',
      createdAt: new Date(now - 2*DAY),
    },

    // IN PROGRESS
    {
      projectNumber: 'AX-10006', userId: client3._id, serviceType: 'assignment',
      title: 'Neural Network Implementation from Scratch',
      subjectId: csSubject && csSubject._id, topic: 'Backpropagation and Gradient Descent',
      description: 'Implement a multi-layer neural network from scratch in Python without using deep learning frameworks.',
      wordCount: 3000, pageCount: 12, referenceStyleId: ieee && ieee._id,
      specificInstructions: 'Only use NumPy. Include training visualizations.',
      focusAreas: ['Backpropagation', 'Gradient Descent', 'Activation Functions'],
      deadline: new Date(now + 4*DAY), originalDeadline: new Date(now + 4*DAY),
      status: 'in_progress', statusUpdatedAt: new Date(now - 3*DAY),
      supervisorId: supervisor._id, doerId: doer1._id,
      pricing: { userQuote: 4000, finalQuote: 4000, doerPayout: 2800, supervisorCommission: 600, platformFee: 600 },
      payment: { isPaid: true, paidAt: new Date(now - 4*DAY), paymentId: 'pay_jt003' },
      delivery: { expectedDeliveryAt: new Date(now + 3*DAY) },
      progressPercentage: 70, source: 'web', clientName: 'Amit Kumar',
      createdAt: new Date(now - 5*DAY),
    },
    {
      projectNumber: 'AX-10007', userId: client1._id, serviceType: 'thesis',
      title: 'Blockchain in Supply Chain Management',
      subjectId: engSubject && engSubject._id, topic: 'Decentralized Supply Chain Tracking Using Blockchain',
      description: 'Thesis chapter on blockchain-based supply chain management covering smart contracts, traceability, and case studies.',
      wordCount: 8000, pageCount: 32, referenceStyleId: apa && apa._id,
      focusAreas: ['Smart Contracts', 'Traceability', 'Case Studies'],
      deadline: new Date(now + 15*DAY), originalDeadline: new Date(now + 15*DAY),
      status: 'in_progress', statusUpdatedAt: new Date(now - 5*DAY),
      supervisorId: supervisor._id, doerId: doer2._id,
      pricing: { userQuote: 8000, finalQuote: 8000, doerPayout: 5600, supervisorCommission: 1200, platformFee: 1200 },
      payment: { isPaid: true, paidAt: new Date(now - 6*DAY), paymentId: 'pay_jt004' },
      delivery: { expectedDeliveryAt: new Date(now + 13*DAY) },
      progressPercentage: 35, source: 'web', clientName: 'Rahul Sharma',
      createdAt: new Date(now - 7*DAY),
    },

    // SUBMITTED FOR QC
    {
      projectNumber: 'AX-10008', userId: client2._id, serviceType: 'assignment',
      title: 'Operating Systems: Process Scheduling',
      subjectId: csSubject && csSubject._id, topic: 'CPU Scheduling Algorithms Comparison',
      description: 'Compare FCFS, SJF, Round Robin, and Priority scheduling with Gantt charts and turnaround time calculations.',
      wordCount: 3000, pageCount: 12, referenceStyleId: ieee && ieee._id,
      deadline: new Date(now + 2*DAY), originalDeadline: new Date(now + 2*DAY),
      status: 'submitted_for_qc', statusUpdatedAt: new Date(now - 6*3600000),
      supervisorId: supervisor._id, doerId: doer1._id,
      pricing: { userQuote: 2500, finalQuote: 2500, doerPayout: 1750, supervisorCommission: 375, platformFee: 375 },
      payment: { isPaid: true, paidAt: new Date(now - 5*DAY), paymentId: 'pay_jt005' },
      delivery: { deliveredAt: new Date(now - 6*3600000), expectedDeliveryAt: new Date(now + 1*DAY) },
      qualityCheck: { aiScore: 91, plagiarismScore: 4 },
      progressPercentage: 100, source: 'web', clientName: 'Priya Patel',
      createdAt: new Date(now - 6*DAY),
    },
    {
      projectNumber: 'AX-10009', userId: client3._id, serviceType: 'report',
      title: 'Financial Ratio Analysis: Infosys Ltd',
      subjectId: econSubject && econSubject._id, topic: 'Financial Performance Analysis 2020-2025',
      description: 'Comprehensive financial analysis using ratio analysis, trend analysis, and peer comparison for Infosys Ltd.',
      wordCount: 4000, pageCount: 16, referenceStyleId: harvard && harvard._id,
      deadline: new Date(now + 3*DAY), originalDeadline: new Date(now + 3*DAY),
      status: 'submitted_for_qc', statusUpdatedAt: new Date(now - 3*3600000),
      supervisorId: supervisor._id, doerId: doer3._id,
      pricing: { userQuote: 3000, finalQuote: 3000, doerPayout: 2100, supervisorCommission: 450, platformFee: 450 },
      payment: { isPaid: true, paidAt: new Date(now - 4*DAY), paymentId: 'pay_jt006' },
      delivery: { deliveredAt: new Date(now - 3*3600000), expectedDeliveryAt: new Date(now + 2*DAY) },
      qualityCheck: { aiScore: 88, plagiarismScore: 6 },
      progressPercentage: 100, source: 'app', clientName: 'Amit Kumar',
      createdAt: new Date(now - 5*DAY),
    },

    // COMPLETED
    {
      projectNumber: 'AX-10010', userId: client1._id, serviceType: 'assignment',
      title: 'Data Structures: AVL Trees Implementation',
      subjectId: csSubject && csSubject._id, topic: 'Self-Balancing BST Operations',
      description: 'Implement AVL tree with insert, delete, and rotation operations in C++.',
      wordCount: 2500, pageCount: 10, referenceStyleId: ieee && ieee._id,
      deadline: new Date(now - 5*DAY), originalDeadline: new Date(now - 5*DAY),
      status: 'completed', statusUpdatedAt: new Date(now - 6*DAY),
      supervisorId: supervisor._id, doerId: doer1._id,
      pricing: { userQuote: 2000, finalQuote: 2000, doerPayout: 1400, supervisorCommission: 300, platformFee: 300 },
      payment: { isPaid: true, paidAt: new Date(now - 12*DAY), paymentId: 'pay_jt007' },
      delivery: { deliveredAt: new Date(now - 7*DAY), expectedDeliveryAt: new Date(now - 6*DAY), completedAt: new Date(now - 5*DAY) },
      qualityCheck: { aiScore: 95, plagiarismScore: 2 },
      progressPercentage: 100,
      userApproval: { approved: true, approvedAt: new Date(now - 5*DAY), feedback: 'Perfect implementation!', grade: 'A' },
      source: 'web', clientName: 'Rahul Sharma',
      createdAt: new Date(now - 14*DAY),
    },
    {
      projectNumber: 'AX-10011', userId: client2._id, serviceType: 'report',
      title: 'Sentiment Analysis of Product Reviews',
      subjectId: dsSubject && dsSubject._id, topic: 'NLP-based Sentiment Analysis using Python',
      description: 'Analyze Amazon product reviews using NLP techniques with word clouds, sentiment scores, and model comparison.',
      wordCount: 5000, pageCount: 20, referenceStyleId: apa && apa._id,
      deadline: new Date(now - 3*DAY), originalDeadline: new Date(now - 3*DAY),
      status: 'completed', statusUpdatedAt: new Date(now - 4*DAY),
      supervisorId: supervisor._id, doerId: doer2._id,
      pricing: { userQuote: 4500, finalQuote: 4500, doerPayout: 3150, supervisorCommission: 675, platformFee: 675 },
      payment: { isPaid: true, paidAt: new Date(now - 10*DAY), paymentId: 'pay_jt008' },
      delivery: { deliveredAt: new Date(now - 5*DAY), expectedDeliveryAt: new Date(now - 4*DAY), completedAt: new Date(now - 3*DAY) },
      qualityCheck: { aiScore: 93, plagiarismScore: 3 },
      progressPercentage: 100,
      userApproval: { approved: true, approvedAt: new Date(now - 3*DAY), feedback: 'Excellent analysis with great visualizations.', grade: 'A+' },
      source: 'web', clientName: 'Priya Patel',
      createdAt: new Date(now - 12*DAY),
    },
  ];

  await db.collection('projects').insertMany(projectData);
  console.log('Created', projectData.length, 'projects');

  // 7. Supervisor wallet
  let wallet = await db.collection('supervisorwallets').findOne({ supervisorId: supervisor._id });
  if (!wallet) {
    const r = await db.collection('supervisorwallets').insertOne({
      supervisorId: supervisor._id,
      balance: 12750, currency: 'INR',
      totalCredited: 67500, totalDebited: 54750,
      totalWithdrawn: 45000, lockedAmount: 975,
      createdAt: new Date(),
    });
    wallet = { _id: r.insertedId };
  }
  console.log('Wallet ready');

  // 8. Wallet transactions
  await db.collection('wallettransactions').insertMany([
    { walletId: wallet._id, walletType: 'supervisor', transactionType: 'credit', amount: 300, status: 'completed', description: 'Commission: AVL Trees Implementation', referenceType: 'project', balanceBefore: 12450, balanceAfter: 12750, createdAt: new Date(now - 5*DAY) },
    { walletId: wallet._id, walletType: 'supervisor', transactionType: 'credit', amount: 675, status: 'completed', description: 'Commission: Sentiment Analysis Report', referenceType: 'project', balanceBefore: 11775, balanceAfter: 12450, createdAt: new Date(now - 4*DAY) },
    { walletId: wallet._id, walletType: 'supervisor', transactionType: 'withdrawal', amount: 5000, status: 'completed', description: 'Bank withdrawal to HDFC ****7654', referenceType: 'payout', balanceBefore: 16775, balanceAfter: 11775, createdAt: new Date(now - 10*DAY) },
    { walletId: wallet._id, walletType: 'supervisor', transactionType: 'credit', amount: 600, status: 'completed', description: 'Commission: Neural Network Assignment', referenceType: 'project', balanceBefore: 16175, balanceAfter: 16775, createdAt: new Date(now - 12*DAY) },
    { walletId: wallet._id, walletType: 'supervisor', transactionType: 'credit', amount: 1200, status: 'completed', description: 'Commission: Blockchain Thesis', referenceType: 'project', balanceBefore: 14975, balanceAfter: 16175, createdAt: new Date(now - 14*DAY) },
    { walletId: wallet._id, walletType: 'supervisor', transactionType: 'credit', amount: 525, status: 'completed', description: 'Commission: Database Systems Assignment', referenceType: 'project', balanceBefore: 14450, balanceAfter: 14975, createdAt: new Date(now - 16*DAY) },
    { walletId: wallet._id, walletType: 'supervisor', transactionType: 'withdrawal', amount: 10000, status: 'completed', description: 'Bank withdrawal to HDFC ****7654', referenceType: 'payout', balanceBefore: 24450, balanceAfter: 14450, createdAt: new Date(now - 20*DAY) },
    { walletId: wallet._id, walletType: 'supervisor', transactionType: 'credit', amount: 375, status: 'pending', description: 'Commission: OS Process Scheduling (pending QC)', referenceType: 'project', balanceBefore: 12750, balanceAfter: 13125, createdAt: new Date(now - 6*3600000) },
    { walletId: wallet._id, walletType: 'supervisor', transactionType: 'bonus', amount: 2000, status: 'completed', description: 'Monthly performance bonus - March 2026', referenceType: 'bonus', balanceBefore: 22450, balanceAfter: 24450, createdAt: new Date(now - 22*DAY) },
  ]);
  console.log('Transactions created');

  // 9. Chat rooms for active projects
  const activeProjects = await db.collection('projects').find({
    supervisorId: supervisor._id,
    status: { $in: ['in_progress', 'submitted_for_qc'] },
  }).toArray();

  for (const proj of activeProjects) {
    if (!proj.doerId) continue;
    const existing = await db.collection('chatrooms').findOne({ projectId: proj._id });
    if (existing) continue;

    const roomResult = await db.collection('chatrooms').insertOne({
      projectId: proj._id, roomType: 'project_all',
      name: 'Chat: ' + proj.title,
      participants: [
        { id: proj.userId, role: 'user', joinedAt: new Date(), isActive: true },
        { id: supervisor._id, role: 'supervisor', joinedAt: new Date(), isActive: true },
        { id: proj.doerId, role: 'doer', joinedAt: new Date(), isActive: true },
      ],
      lastMessageAt: new Date(now - 2*3600000), createdAt: new Date(),
    });

    await db.collection('chatmessages').insertMany([
      { chatRoomId: roomResult.insertedId, senderId: proj.userId, senderRole: 'user', messageType: 'text', content: 'Hi, any updates on my project?', readBy: [{ id: proj.userId, role: 'user' }], createdAt: new Date(now - 1*DAY) },
      { chatRoomId: roomResult.insertedId, senderId: supervisor._id, senderRole: 'supervisor', messageType: 'text', content: 'The doer is making good progress. Will update you once the draft is ready.', readBy: [{ id: supervisor._id, role: 'supervisor' }, { id: proj.userId, role: 'user' }], createdAt: new Date(now - 1*DAY + 3600000) },
      { chatRoomId: roomResult.insertedId, senderId: proj.doerId, senderRole: 'doer', messageType: 'text', content: 'Working on the core sections now. Will share a draft by tomorrow.', readBy: [{ id: proj.doerId, role: 'doer' }], createdAt: new Date(now - 12*3600000) },
    ]);
  }
  console.log('Chat rooms created');

  // 10. Notifications
  await db.collection('notifications').insertMany([
    { recipientId: supervisor._id, recipientRole: 'supervisor', type: 'project_assigned', title: 'New Project Assigned', message: 'You have been assigned to supervise "Machine Learning Classification Project"', data: {}, isRead: false, createdAt: new Date(now - 2*3600000) },
    { recipientId: supervisor._id, recipientRole: 'supervisor', type: 'project_assigned', title: 'New Project Assigned', message: 'You have been assigned to supervise "Market Research: EV Industry Analysis"', data: {}, isRead: false, createdAt: new Date(now - 5*3600000) },
    { recipientId: supervisor._id, recipientRole: 'supervisor', type: 'review_needed', title: 'QC Review Required', message: 'Project "Operating Systems: Process Scheduling" is ready for your quality check.', data: {}, isRead: false, createdAt: new Date(now - 6*3600000) },
    { recipientId: supervisor._id, recipientRole: 'supervisor', type: 'review_needed', title: 'QC Review Required', message: 'Project "Financial Ratio Analysis: Infosys" is ready for quality review.', data: {}, isRead: false, createdAt: new Date(now - 3*3600000) },
    { recipientId: supervisor._id, recipientRole: 'supervisor', type: 'payment_received', title: 'Commission Earned', message: 'You earned Rs 675 commission for "Sentiment Analysis of Product Reviews".', data: {}, isRead: true, readAt: new Date(now - 3*DAY), createdAt: new Date(now - 4*DAY) },
    { recipientId: supervisor._id, recipientRole: 'supervisor', type: 'payment_received', title: 'Commission Earned', message: 'You earned Rs 300 commission for "AVL Trees Implementation".', data: {}, isRead: true, readAt: new Date(now - 4*DAY), createdAt: new Date(now - 5*DAY) },
    { recipientId: supervisor._id, recipientRole: 'supervisor', type: 'new_message', title: 'New Chat Message', message: 'New message in "Neural Network Implementation" project chat.', data: {}, isRead: false, createdAt: new Date(now - 12*3600000) },
    { recipientId: supervisor._id, recipientRole: 'supervisor', type: 'system', title: 'Monthly Report Ready', message: 'Your March 2026 performance report is ready. Check your earnings dashboard.', data: {}, isRead: false, createdAt: new Date(now - 1*DAY) },
  ]);
  console.log('Notifications created');

  // 11. Support ticket
  await db.collection('supporttickets').insertOne({
    raisedById: supervisor._id, raisedByRole: 'supervisor',
    userName: supervisor.fullName || 'Jasvin Taneja',
    subject: 'Withdrawal processing time',
    description: 'My last withdrawal is taking longer than expected.',
    category: 'billing', priority: 'medium', status: 'open',
    messages: [{
      senderId: supervisor._id, senderName: supervisor.fullName || 'Jasvin Taneja',
      senderRole: 'supervisor',
      message: 'My withdrawal from 5 days ago is still processing. Usually it takes 2-3 days.',
      createdAt: new Date(now - 2*DAY),
    }],
    createdAt: new Date(now - 2*DAY),
  });
  console.log('Support ticket created');

  console.log('\n===== SEED COMPLETE =====');
  console.log('Supervisor:', email);
  console.log('Projects: 11 (3 submitted, 2 paid, 2 in_progress, 2 submitted_for_qc, 2 completed)');
  console.log('Doers: 3 (Ananya, Vikram, Sneha)');
  console.log('Clients: 3 (Rahul, Priya, Amit)');
  console.log('Wallet: Rs 12,750 balance');
  console.log('Transactions: 9');
  console.log('Notifications: 8');

  await mongoose.disconnect();
}

seed().catch(e => { console.error('Seed failed:', e); process.exit(1); });
