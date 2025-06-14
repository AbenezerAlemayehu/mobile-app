const mongoose = require('mongoose');

const tripSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    title: { type: String, required: true },
    description: { type: String, required: true },
    location: { type: String, required: true },
    startDate: { type: Date, required: true },
    endDate: { type: Date },
    budget: { type: Number },
    numberOfPeople: { type: Number, default: 1 },
    imagePath: {
        type: String,
        validate: {
            validator: function(v) {
                return !v || /^\/uploads\/.+\.(jpg|jpeg|png|gif)$/i.test(v);
            },
            message: 'Image path must be a valid image file in the uploads directory'
        }
    },
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Trip', tripSchema);