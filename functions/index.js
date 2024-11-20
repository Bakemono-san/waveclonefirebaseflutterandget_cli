const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.createTransactionsDaily = functions.pubsub
  .schedule('0 0 * * *')  // Cron expression to run at midnight every day
  .timeZone('Europe/Paris')  // Adjust this timezone to your needs
  .onRun(async (context) => {
    console.log('Triggered daily job at midnight');

    try {
      // Fetch all documents from the 'plannifications' collection
      const plannificationsSnapshot = await admin.firestore()
        .collection('plannifications')
        .where('deleted', '==', false)  // Ensure we only fetch non-deleted entries
        .get();

      if (plannificationsSnapshot.empty) {
        console.log('No plannifications found');
        return;
      }

      // Process each document
      const batch = admin.firestore().batch(); // Use batch writes to perform multiple writes atomically
      plannificationsSnapshot.forEach(async (doc) => {
        const data = doc.data();
        console.log('Processing plannification:', data);

        const senderSnapshot = await admin.firestore().collection('users').where('telephone', '==', data.senderTelephone).get();
        const receiverSnapshot = await admin.firestore().collection('users').where('telephone', '==', data.receiverTelephone).get();

        const senderUser = senderSnapshot.docs.length > 0 ? senderSnapshot.docs[0].data() : null;
        const receiverUser = receiverSnapshot.docs.length > 0 ? receiverSnapshot.docs[0].data() : null;

        const senderaccountnapshot = await admin.firestore().collection('accounts').where('id', '==', senderUser.account_id).get();
        const receiveraccountnapshot = await admin.firestore().collection('accounts').where('id', '==', receiverUser.account_id).get();

        const senderContact = senderaccountnapshot.docs.length > 0 ? senderaccountnapshot.docs[0].data() : null;
        const receiverContact = receiveraccountnapshot.docs.length > 0 ? receiveraccountnapshot.docs[0].data() : null;

        if(senderContact.solde < data.montant) {
          console.log('Sender solde insufficient');
          return;
        }

        // Create a new transaction document in 'transactions'
        const transactionRef = admin.firestore().collection('transactions').doc(); // Auto generate ID
        const transactionData = {
          montant: data.montant,
          annulee: false,
          deleted: false,
          type: 'Transfert',
          date: admin.firestore.FieldValue.serverTimestamp(),
          deletedAt: null,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          senderTelephone: data.senderTelephone || null,
          receiverTelephone: data.receiverTelephone || null,
        };



        senderContact.solde = senderContact.solde - data.montant;
        receiverContact.solde = receiverContact.solde + data.montant;

        await admin.firestore().collection('account').doc(senderContact.id).set(senderContact);
        await admin.firestore().collection('account').doc(receiverContact.id).set(receiverContact);

        // Add the transaction to the batch
        batch.set(transactionRef, transactionData);
      });

      // Commit the batch write to Firestore
      await batch.commit();
      console.log('Transactions created successfully');
    } catch (error) {
      console.error('Error processing plannifications:', error);
    }
  });
