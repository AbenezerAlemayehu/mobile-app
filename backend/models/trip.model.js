const mongoose = require('mongoose');

const tripSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    title: { type: String, required: true },
    description: { type: String, required: true },
    location: { type: String, required: true },
    startDate: { type: Date, required: true },
    endDate: { type: Date },
    createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Trip', tripSchema);