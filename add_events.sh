#!/bin/bash

# Script to add sample events to Firestore using Firebase CLI

echo "Adding sample events to Firestore..."

# Event 1: Dubai Startup Networking Mixer
firebase firestore:set discoveredEvents/sample-event-1 '{
  "eventName": "Dubai Startup Networking Mixer",
  "date": "2025-11-05",
  "time": "18:00",
  "location": {
    "venue": "DIFC Innovation Hub",
    "address": "Gate Village, Dubai International Financial Centre"
  },
  "category": "Networking",
  "sourceURL": "https://www.eventbrite.ae/sample-event-1",
  "description": "Join fellow entrepreneurs and startup founders for an evening of networking, insights, and collaboration in the heart of Dubais financial district.",
  "attendees": 45
}' --project business-setup-application

# Event 2
firebase firestore:set discoveredEvents/sample-event-2 '{
  "eventName": "Digital Marketing Workshop for SMEs",
  "date": "2025-11-08",
  "time": "14:00",
  "location": {
    "venue": "Dubai Internet City",
    "address": "Building 10, Dubai Internet City"
  },
  "category": "Workshop",
  "sourceURL": "https://www.meetup.com/sample-event-2",
  "description": "Learn the latest digital marketing strategies tailored for small and medium enterprises in the UAE market.",
  "attendees": 32
}' --project business-setup-application

# Event 3
firebase firestore:set discoveredEvents/sample-event-3 '{
  "eventName": "UAE Business Conference 2025",
  "date": "2025-11-12",
  "time": "09:00",
  "location": {
    "venue": "Dubai World Trade Centre",
    "address": "Sheikh Zayed Road, Dubai"
  },
  "category": "Conference",
  "sourceURL": "https://www.lovin.co/sample-event-3",
  "description": "The premier business conference bringing together industry leaders, investors, and innovators from across the UAE and GCC region.",
  "attendees": 250
}' --project business-setup-application

# Event 4
firebase firestore:set discoveredEvents/sample-event-4 '{
  "eventName": "AI & Innovation Pitch Competition",
  "date": "2025-11-15",
  "time": "10:00",
  "location": {
    "venue": "Area 2071",
    "address": "Emirates Towers, Sheikh Zayed Road"
  },
  "category": "Competition",
  "sourceURL": "https://www.eventbrite.ae/sample-event-4",
  "description": "Pitch your AI-powered startup to a panel of leading investors and win funding, mentorship, and exposure.",
  "attendees": 120
}' --project business-setup-application

# Event 5
firebase firestore:set discoveredEvents/sample-event-5 '{
  "eventName": "Free Zone Setup Masterclass",
  "date": "2025-11-10",
  "time": "16:00",
  "location": {
    "venue": "Virtual Event",
    "address": null
  },
  "category": "Workshop",
  "sourceURL": "https://www.meetup.com/sample-event-5",
  "description": "Everything you need to know about setting up your business in a UAE free zone. Expert advice on licenses, visas, and costs.",
  "attendees": 89
}' --project business-setup-application

echo "✅ Sample events added! Check your app now."
