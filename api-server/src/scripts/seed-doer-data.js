const mongoose = require('mongoose');
const fs = require('fs');
const os = require('os');

const URI = 'mongodb+srv://omrajpal:1122334455@cluster0.tva2yqz.mongodb.net/AssignX?retryWrites=true&w=majority&appName=Cluster0';
const log = [];
const L = (msg) => { log.push(msg); };

(async () => {
  try {
    await mongoose.connect(URI);
    const db = mongoose.connection.db;
    const email = 'jasvintaneja2307@gmail.com';
    const now = Date.now();
    const DAY = 86400000;

    // 1. Get doer
    const doer = await db.collection('doers').findOne({ email });
    if (!doer) { L('ERROR: No doer found'); return; }
    L('Doer: ' + doer._id + ' ' + doer.fullName);

    // 2. Get subjects
    const subjects = await db.collection('subjects').find({}).toArray();
    const csSubject = subjects.find(s => s.slug === 'computer-science');
    const dsSubject = subjects.find(s => s.slug === 'data-science');
    const engSubject = subjects.find(s => s.slug === 'engineering');
    const econSubject = subjects.find(s => s.slug === 'economics');

    // 3. Update doer profile with full data
    await db.collection('doers').updateOne({ _id: doer._id }, { $set: {
      isActive: true,
      isActivated: true,
      isAccessGranted: true,
      onboardingCompleted: true,
      trainingCompleted: true,
      qualification: 'postgraduate',
      universityName: 'Delhi University',
      experienceLevel: 'intermediate',
      yearsOfExperience: 3,
      bio: 'Experienced academic writer specializing in Computer Science, Data Analysis, and Engineering projects.',
      isAvailable: true,
      maxConcurrentProjects: 5,
      totalEarnings: 52000,
      totalProjectsCompleted: 22,
      averageRating: 4.6,
      totalReviews: 18,
      successRate: 95,
      onTimeDeliveryRate: 92,
      subjects: [
        csSubject && { subjectId: csSubject._id, isPrimary: true },
        dsSubject && { subjectId: dsSubject._id, isPrimary: false },
        engSubject && { subjectId: engSubject._id, isPrimary: false },
      ].filter(Boolean),
    }});
    L('Updated doer profile');

    // 4. Get/create supervisors for the projects
    let sup1 = await db.collection('supervisors').findOne({ email: 'jasvintaneja2307@gmail.com' });
    if (!sup1) {
      sup1 = await db.collection('supervisors').findOne({});
    }
    L('Supervisor: ' + (sup1 ? sup1._id : 'none'));

    // 5. Get/create clients
    const ensureUser = async (ue, fn, ph, ut) => {
      let u = await db.collection('users').findOne({ email: ue });
      if (!u) {
        const r = await db.collection('users').insertOne({ email: ue, fullName: fn, phone: ph, userType: ut, onboardingCompleted: true, refreshTokens: [], createdAt: new Date() });
        return { _id: r.insertedId, fullName: fn };
      }
      return { _id: u._id, fullName: u.fullName || fn };
    };

    const client1 = await ensureUser('rahul.sharma.test@gmail.com', 'Rahul Sharma', '+91-9876500001', 'student');
    const client2 = await ensureUser('priya.patel.test@gmail.com', 'Priya Patel', '+91-9876500002', 'professional');
    const client3 = await ensureUser('amit.kumar.test@gmail.com', 'Amit Kumar', '+91-9876500003', 'student');
    const client4 = await ensureUser('neha.verma.test@gmail.com', 'Neha Verma', '+91-9876500004', 'student');
    L('Clients ready');

    // 6. Get reference styles
    const refStyles = await db.collection('referencestyles').find({}).toArray();
    const apa = refStyles.find(r => r.name && r.name.includes('APA'));
    const ieee = refStyles.find(r => r.name && r.name.includes('IEEE'));
    const harvard = refStyles.find(r => r.name && r.name.includes('Harvard'));

    // 7. Create projects assigned to this doer
    const supId = sup1 ? sup1._id : null;

    const projectData = [
      // ASSIGNED (just got assigned, not started yet)
      {
        projectNumber: 'AX-20001', userId: client1._id, serviceType: 'assignment',
        title: 'React Native Mobile App Architecture',
        subjectId: csSubject && csSubject._id, topic: 'Cross-Platform Mobile Development Best Practices',
        description: 'Design and document a React Native app architecture with state management, navigation, and API integration patterns.',
        wordCount: 3500, pageCount: 14, referenceStyleId: ieee && ieee._id,
        specificInstructions: 'Include diagrams for component hierarchy and data flow.',
        focusAreas: ['React Native', 'State Management', 'API Integration'],
        deadline: new Date(now + 8 * DAY), originalDeadline: new Date(now + 8 * DAY),
        status: 'assigned', statusUpdatedAt: new Date(now - 1 * DAY),
        supervisorId: supId, doerId: doer._id,
        pricing: { userQuote: 3500, finalQuote: 3500, doerPayout: 2450, supervisorCommission: 525, platformFee: 525 },
        payment: { isPaid: true, paidAt: new Date(now - 2 * DAY), paymentId: 'pay_d001' },
        doerAssignedAt: new Date(now - 1 * DAY),
        progressPercentage: 0, source: 'web', clientName: 'Rahul Sharma',
        createdAt: new Date(now - 3 * DAY),
      },

      // IN PROGRESS
      {
        projectNumber: 'AX-20002', userId: client2._id, serviceType: 'report',
        title: 'Predictive Analytics for E-Commerce',
        subjectId: dsSubject && dsSubject._id, topic: 'Customer Churn Prediction Using Machine Learning',
        description: 'Build a customer churn prediction model using Python. Include data preprocessing, feature engineering, model comparison (Logistic Regression, XGBoost, Random Forest), and evaluation metrics.',
        wordCount: 5000, pageCount: 20, referenceStyleId: apa && apa._id,
        specificInstructions: 'Use Jupyter notebooks. Include confusion matrix and ROC curve for each model.',
        focusAreas: ['Churn Prediction', 'XGBoost', 'Feature Engineering'],
        deadline: new Date(now + 5 * DAY), originalDeadline: new Date(now + 5 * DAY),
        status: 'in_progress', statusUpdatedAt: new Date(now - 4 * DAY),
        supervisorId: supId, doerId: doer._id,
        pricing: { userQuote: 5000, finalQuote: 5000, doerPayout: 3500, supervisorCommission: 750, platformFee: 750 },
        payment: { isPaid: true, paidAt: new Date(now - 5 * DAY), paymentId: 'pay_d002' },
        delivery: { expectedDeliveryAt: new Date(now + 4 * DAY) },
        doerAssignedAt: new Date(now - 4 * DAY),
        progressPercentage: 55, source: 'web', clientName: 'Priya Patel',
        createdAt: new Date(now - 6 * DAY),
      },
      {
        projectNumber: 'AX-20003', userId: client3._id, serviceType: 'assignment',
        title: 'Compiler Design: Lexical Analyzer',
        subjectId: csSubject && csSubject._id, topic: 'Building a Lexer for a Custom Programming Language',
        description: 'Implement a lexical analyzer in C++ that tokenizes a custom language with support for keywords, identifiers, operators, and literals.',
        wordCount: 3000, pageCount: 12, referenceStyleId: ieee && ieee._id,
        specificInstructions: 'Use finite automata approach. Include test cases for edge cases.',
        focusAreas: ['Lexical Analysis', 'Finite Automata', 'Tokenization'],
        deadline: new Date(now + 3 * DAY), originalDeadline: new Date(now + 3 * DAY),
        status: 'in_progress', statusUpdatedAt: new Date(now - 6 * DAY),
        supervisorId: supId, doerId: doer._id,
        pricing: { userQuote: 3000, finalQuote: 3000, doerPayout: 2100, supervisorCommission: 450, platformFee: 450 },
        payment: { isPaid: true, paidAt: new Date(now - 7 * DAY), paymentId: 'pay_d003' },
        delivery: { expectedDeliveryAt: new Date(now + 2 * DAY) },
        doerAssignedAt: new Date(now - 6 * DAY),
        progressPercentage: 80, source: 'app', clientName: 'Amit Kumar',
        createdAt: new Date(now - 8 * DAY),
      },

      // SUBMITTED FOR QC (doer submitted, waiting for supervisor review)
      {
        projectNumber: 'AX-20004', userId: client4._id, serviceType: 'essay',
        title: 'Cloud Computing Security Challenges',
        subjectId: csSubject && csSubject._id, topic: 'Security Vulnerabilities in Multi-Tenant Cloud Environments',
        description: 'Comprehensive essay on security challenges in cloud computing including data breaches, insecure APIs, and shared technology vulnerabilities.',
        wordCount: 4000, pageCount: 16, referenceStyleId: apa && apa._id,
        deadline: new Date(now + 2 * DAY), originalDeadline: new Date(now + 2 * DAY),
        status: 'submitted_for_qc', statusUpdatedAt: new Date(now - 8 * 3600000),
        supervisorId: supId, doerId: doer._id,
        pricing: { userQuote: 2800, finalQuote: 2800, doerPayout: 1960, supervisorCommission: 420, platformFee: 420 },
        payment: { isPaid: true, paidAt: new Date(now - 6 * DAY), paymentId: 'pay_d004' },
        delivery: { deliveredAt: new Date(now - 8 * 3600000), expectedDeliveryAt: new Date(now + 1 * DAY) },
        qualityCheck: { aiScore: 90, plagiarismScore: 5 },
        doerAssignedAt: new Date(now - 5 * DAY),
        progressPercentage: 100, source: 'web', clientName: 'Neha Verma',
        createdAt: new Date(now - 7 * DAY),
      },

      // REVISION REQUESTED
      {
        projectNumber: 'AX-20005', userId: client1._id, serviceType: 'report',
        title: 'IoT-Based Smart Home Automation',
        subjectId: engSubject && engSubject._id, topic: 'Arduino and Raspberry Pi Integration for Home Automation',
        description: 'Technical report on building a smart home system using IoT devices. Include circuit diagrams, code snippets, and cost analysis.',
        wordCount: 4500, pageCount: 18, referenceStyleId: ieee && ieee._id,
        deadline: new Date(now + 4 * DAY), originalDeadline: new Date(now + 1 * DAY),
        status: 'revision_requested', statusUpdatedAt: new Date(now - 1 * DAY),
        supervisorId: supId, doerId: doer._id,
        pricing: { userQuote: 4000, finalQuote: 4000, doerPayout: 2800, supervisorCommission: 600, platformFee: 600 },
        payment: { isPaid: true, paidAt: new Date(now - 10 * DAY), paymentId: 'pay_d005' },
        delivery: { deliveredAt: new Date(now - 2 * DAY), expectedDeliveryAt: new Date(now + 3 * DAY) },
        qualityCheck: { aiScore: 75, plagiarismScore: 12 },
        doerAssignedAt: new Date(now - 8 * DAY),
        progressPercentage: 100, source: 'web', clientName: 'Rahul Sharma',
        createdAt: new Date(now - 12 * DAY),
      },

      // COMPLETED
      {
        projectNumber: 'AX-20006', userId: client2._id, serviceType: 'assignment',
        title: 'Python Web Scraping & Data Pipeline',
        subjectId: dsSubject && dsSubject._id, topic: 'Automated Data Collection from E-Commerce Sites',
        description: 'Build a web scraping pipeline using Scrapy and BeautifulSoup to collect product data and store in PostgreSQL.',
        wordCount: 3000, pageCount: 12, referenceStyleId: apa && apa._id,
        deadline: new Date(now - 5 * DAY), originalDeadline: new Date(now - 5 * DAY),
        status: 'completed', statusUpdatedAt: new Date(now - 6 * DAY),
        supervisorId: supId, doerId: doer._id,
        pricing: { userQuote: 3500, finalQuote: 3500, doerPayout: 2450, supervisorCommission: 525, platformFee: 525 },
        payment: { isPaid: true, paidAt: new Date(now - 14 * DAY), paymentId: 'pay_d006' },
        delivery: { deliveredAt: new Date(now - 7 * DAY), expectedDeliveryAt: new Date(now - 6 * DAY), completedAt: new Date(now - 5 * DAY) },
        qualityCheck: { aiScore: 94, plagiarismScore: 2 },
        doerAssignedAt: new Date(now - 12 * DAY),
        progressPercentage: 100,
        userApproval: { approved: true, approvedAt: new Date(now - 5 * DAY), feedback: 'Excellent scraping pipeline! Very well documented.', grade: 'A' },
        source: 'web', clientName: 'Priya Patel',
        createdAt: new Date(now - 16 * DAY),
      },
      {
        projectNumber: 'AX-20007', userId: client3._id, serviceType: 'thesis',
        title: 'Deep Learning for Medical Image Segmentation',
        subjectId: csSubject && csSubject._id, topic: 'U-Net Architecture for Tumor Detection in MRI Scans',
        description: 'Implement U-Net and its variants for medical image segmentation. Compare performance with Dice coefficient and IoU metrics.',
        wordCount: 8000, pageCount: 32, referenceStyleId: apa && apa._id,
        deadline: new Date(now - 3 * DAY), originalDeadline: new Date(now - 3 * DAY),
        status: 'completed', statusUpdatedAt: new Date(now - 4 * DAY),
        supervisorId: supId, doerId: doer._id,
        pricing: { userQuote: 8000, finalQuote: 8000, doerPayout: 5600, supervisorCommission: 1200, platformFee: 1200 },
        payment: { isPaid: true, paidAt: new Date(now - 18 * DAY), paymentId: 'pay_d007' },
        delivery: { deliveredAt: new Date(now - 5 * DAY), expectedDeliveryAt: new Date(now - 4 * DAY), completedAt: new Date(now - 3 * DAY) },
        qualityCheck: { aiScore: 97, plagiarismScore: 1 },
        doerAssignedAt: new Date(now - 15 * DAY),
        progressPercentage: 100,
        userApproval: { approved: true, approvedAt: new Date(now - 3 * DAY), feedback: 'Outstanding research work! The U-Net implementation is perfect.', grade: 'A+' },
        source: 'web', clientName: 'Amit Kumar',
        createdAt: new Date(now - 20 * DAY),
      },
      {
        projectNumber: 'AX-20008', userId: client4._id, serviceType: 'assignment',
        title: 'Microservices with Node.js & Docker',
        subjectId: csSubject && csSubject._id, topic: 'Building Scalable Microservices Architecture',
        description: 'Design and implement a microservices-based e-commerce backend using Node.js, Express, Docker, and RabbitMQ for message queuing.',
        wordCount: 4000, pageCount: 16, referenceStyleId: ieee && ieee._id,
        deadline: new Date(now - 8 * DAY), originalDeadline: new Date(now - 8 * DAY),
        status: 'completed', statusUpdatedAt: new Date(now - 9 * DAY),
        supervisorId: supId, doerId: doer._id,
        pricing: { userQuote: 4500, finalQuote: 4500, doerPayout: 3150, supervisorCommission: 675, platformFee: 675 },
        payment: { isPaid: true, paidAt: new Date(now - 20 * DAY), paymentId: 'pay_d008' },
        delivery: { deliveredAt: new Date(now - 10 * DAY), expectedDeliveryAt: new Date(now - 9 * DAY), completedAt: new Date(now - 8 * DAY) },
        qualityCheck: { aiScore: 91, plagiarismScore: 3 },
        doerAssignedAt: new Date(now - 18 * DAY),
        progressPercentage: 100,
        userApproval: { approved: true, approvedAt: new Date(now - 8 * DAY), feedback: 'Good implementation. Docker setup was clean.', grade: 'A' },
        source: 'app', clientName: 'Neha Verma',
        createdAt: new Date(now - 22 * DAY),
      },
    ];

    await db.collection('projects').insertMany(projectData);
    L('Created ' + projectData.length + ' projects');

    // 8. Doer wallet
    let wallet = await db.collection('doerwallets').findOne({ doerId: doer._id });
    if (!wallet) {
      const r = await db.collection('doerwallets').insertOne({
        doerId: doer._id, balance: 8750, currency: 'INR',
        totalCredited: 52000, totalDebited: 43250,
        totalWithdrawn: 35000, lockedAmount: 1960,
        createdAt: new Date(),
      });
      wallet = { _id: r.insertedId };
    }
    L('Wallet ready');

    // 9. Wallet transactions
    await db.collection('wallettransactions').insertMany([
      { walletId: wallet._id, walletType: 'doer', transactionType: 'credit', amount: 2450, status: 'completed', description: 'Earnings: Python Web Scraping Pipeline', referenceType: 'project', balanceBefore: 6300, balanceAfter: 8750, createdAt: new Date(now - 5 * DAY) },
      { walletId: wallet._id, walletType: 'doer', transactionType: 'credit', amount: 5600, status: 'completed', description: 'Earnings: Deep Learning Medical Image Segmentation', referenceType: 'project', balanceBefore: 700, balanceAfter: 6300, createdAt: new Date(now - 3 * DAY) },
      { walletId: wallet._id, walletType: 'doer', transactionType: 'credit', amount: 3150, status: 'completed', description: 'Earnings: Microservices with Node.js & Docker', referenceType: 'project', balanceBefore: 12550, balanceAfter: 15700, createdAt: new Date(now - 8 * DAY) },
      { walletId: wallet._id, walletType: 'doer', transactionType: 'withdrawal', amount: 15000, status: 'completed', description: 'Bank withdrawal to SBI ****4321', referenceType: 'payout', balanceBefore: 15700, balanceAfter: 700, createdAt: new Date(now - 7 * DAY) },
      { walletId: wallet._id, walletType: 'doer', transactionType: 'withdrawal', amount: 10000, status: 'completed', description: 'Bank withdrawal to SBI ****4321', referenceType: 'payout', balanceBefore: 22550, balanceAfter: 12550, createdAt: new Date(now - 15 * DAY) },
      { walletId: wallet._id, walletType: 'doer', transactionType: 'credit', amount: 2800, status: 'completed', description: 'Earnings: IoT Smart Home Automation', referenceType: 'project', balanceBefore: 19750, balanceAfter: 22550, createdAt: new Date(now - 12 * DAY) },
      { walletId: wallet._id, walletType: 'doer', transactionType: 'bonus', amount: 1500, status: 'completed', description: 'Performance bonus — March 2026', referenceType: 'bonus', balanceBefore: 18250, balanceAfter: 19750, createdAt: new Date(now - 18 * DAY) },
      { walletId: wallet._id, walletType: 'doer', transactionType: 'credit', amount: 1960, status: 'pending', description: 'Earnings: Cloud Computing Security (pending QC)', referenceType: 'project', balanceBefore: 8750, balanceAfter: 10710, createdAt: new Date(now - 8 * 3600000) },
    ]);
    L('Transactions created');

    // 10. Chat rooms for active projects
    const activeProjects = await db.collection('projects').find({
      doerId: doer._id,
      status: { $in: ['in_progress', 'submitted_for_qc', 'revision_requested'] },
    }).toArray();

    for (const proj of activeProjects) {
      const existing = await db.collection('chatrooms').findOne({ projectId: proj._id });
      if (existing) continue;
      const roomResult = await db.collection('chatrooms').insertOne({
        projectId: proj._id, roomType: 'project_all',
        name: 'Chat: ' + proj.title,
        participants: [
          { id: proj.userId, role: 'user', joinedAt: new Date(), isActive: true },
          proj.supervisorId && { id: proj.supervisorId, role: 'supervisor', joinedAt: new Date(), isActive: true },
          { id: doer._id, role: 'doer', joinedAt: new Date(), isActive: true },
        ].filter(Boolean),
        lastMessageAt: new Date(now - 3 * 3600000), createdAt: new Date(),
      });
      await db.collection('chatmessages').insertMany([
        { chatRoomId: roomResult.insertedId, senderId: proj.userId, senderRole: 'user', messageType: 'text', content: 'Hi, how is the progress going?', readBy: [{ id: proj.userId, role: 'user' }], createdAt: new Date(now - 1 * DAY) },
        { chatRoomId: roomResult.insertedId, senderId: doer._id, senderRole: 'doer', messageType: 'text', content: 'Making good progress! Will share an update soon.', readBy: [{ id: doer._id, role: 'doer' }], createdAt: new Date(now - 20 * 3600000) },
      ]);
    }
    L('Chat rooms created');

    // 11. Notifications
    await db.collection('notifications').insertMany([
      { recipientId: doer._id, recipientRole: 'doer', type: 'project_assigned', title: 'New Project Assigned', message: 'You have been assigned to "React Native Mobile App Architecture"', data: {}, isRead: false, createdAt: new Date(now - 1 * DAY) },
      { recipientId: doer._id, recipientRole: 'doer', type: 'revision_requested', title: 'Revision Requested', message: 'Supervisor requested revisions on "IoT Smart Home Automation". Plagiarism score needs improvement.', data: {}, isRead: false, createdAt: new Date(now - 1 * DAY) },
      { recipientId: doer._id, recipientRole: 'doer', type: 'payment_received', title: 'Payment Received', message: 'You earned Rs 5,600 for "Deep Learning Medical Image Segmentation"', data: {}, isRead: false, createdAt: new Date(now - 3 * DAY) },
      { recipientId: doer._id, recipientRole: 'doer', type: 'payment_received', title: 'Payment Received', message: 'You earned Rs 2,450 for "Python Web Scraping Pipeline"', data: {}, isRead: true, readAt: new Date(now - 4 * DAY), createdAt: new Date(now - 5 * DAY) },
      { recipientId: doer._id, recipientRole: 'doer', type: 'deadline_reminder', title: 'Deadline Approaching', message: 'Project "Compiler Design: Lexical Analyzer" deadline is in 3 days.', data: {}, isRead: false, createdAt: new Date(now - 12 * 3600000) },
      { recipientId: doer._id, recipientRole: 'doer', type: 'project_completed', title: 'Project Completed', message: 'Client approved "Deep Learning Medical Image Segmentation" with grade A+!', data: {}, isRead: true, readAt: new Date(now - 2 * DAY), createdAt: new Date(now - 3 * DAY) },
      { recipientId: doer._id, recipientRole: 'doer', type: 'new_message', title: 'New Chat Message', message: 'New message from client on "Predictive Analytics for E-Commerce"', data: {}, isRead: false, createdAt: new Date(now - 1 * DAY) },
      { recipientId: doer._id, recipientRole: 'doer', type: 'system', title: 'Earnings Report Ready', message: 'Your March 2026 earnings report is ready. Total: Rs 11,200', data: {}, isRead: false, createdAt: new Date(now - 2 * DAY) },
    ]);
    L('Notifications created');

    // 12. Doer reviews
    await db.collection('doerreviews').insertMany([
      { doerId: doer._id, reviewerId: client2._id, rating: 5, review: 'Excellent scraping pipeline! Very well documented and clean code.', createdAt: new Date(now - 5 * DAY) },
      { doerId: doer._id, reviewerId: client3._id, rating: 5, review: 'Outstanding U-Net implementation. The research quality was exceptional.', createdAt: new Date(now - 3 * DAY) },
      { doerId: doer._id, reviewerId: client4._id, rating: 4, review: 'Good Docker setup and microservices architecture. Delivered on time.', createdAt: new Date(now - 8 * DAY) },
    ]);
    L('Reviews created');

    L('\n===== SEED COMPLETE =====');
    L('Doer: ' + email);
    L('Projects: 8 (1 assigned, 2 in_progress, 1 submitted_for_qc, 1 revision_requested, 3 completed)');
    L('Wallet: Rs 8,750 balance');
    L('Transactions: 8');
    L('Notifications: 8');
    L('Reviews: 3');

    await mongoose.disconnect();
  } catch (e) {
    L('FAILED: ' + e.message + '\n' + e.stack);
  } finally {
    fs.writeFileSync(os.tmpdir() + '/doer_seed.txt', log.join('\n'));
    process.exit(0);
  }
})();
