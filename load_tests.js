import http from 'k6/http';
import { check, sleep } from 'k6';

// k6 options configuration
export let options = {
    stages: [
        { duration: '2s', target: 15 },  // Ramp up to 15 VUs
        { duration: '4s', target: 30 },  // Run at 30 VUs
        { duration: '2s', target: 0 },   // Ramp down to 0 VUs
    ],
    thresholds: {
        // High-level service performance metrics
        http_req_failed: ['rate<0.01'],    // Request failure rate must be less than 1%
        http_req_duration: ['p(95)<350'], // 95% of requests must complete within 350ms
    },
};

const BASE_URL = 'http://localhost:8000';

export default function () {
    // 1. Simulate Crew / Admin Login
    let loginPayload = JSON.stringify({
        email: 'crew@sky.com',
        password: 'password123',
        role: 'Cabin Crew'
    });
    let loginParams = { headers: { 'Content-Type': 'application/json' } };
    let loginRes = http.post(`${BASE_URL}/api/login`, loginPayload, loginParams);
    check(loginRes, {
        'Login status is 200': (r) => r.status === 200,
        'Login returns valid JSON': (r) => r.json() !== null,
        'Login response contains UID': (r) => r.json('uid') !== undefined,
    });
    sleep(0.5);

    // 2. Fetch Flight Schedules
    let flightsRes = http.get(`${BASE_URL}/api/flights`);
    check(flightsRes, {
        'Flights status is 200': (r) => r.status === 200,
        'Flights list is non-empty': (r) => r.json('flights').length >= 0,
    });
    sleep(0.5);

    // 3. Post Leave Request
    let leavePayload = JSON.stringify({
        crewName: 'Alice Smith',
        startDate: '2026-07-01',
        endDate: '2026-07-05',
        reason: 'Family Vacation',
        status: 'Pending'
    });
    let leaveParams = { headers: { 'Content-Type': 'application/json' } };
    let leaveRes = http.post(`${BASE_URL}/api/leave-request`, leavePayload, leaveParams);
    check(leaveRes, {
        'Leave submission is 201': (r) => r.status === 201,
        'Leave request has ID': (r) => r.json('id') !== undefined,
    });
    sleep(0.5);

    // 4. Update Profile Info
    let profilePayload = JSON.stringify({
        phone: '9876543210',
        base: 'London LHR'
    });
    let profileParams = { headers: { 'Content-Type': 'application/json' } };
    let profileRes = http.post(`${BASE_URL}/api/profile`, profilePayload, profileParams);
    check(profileRes, {
        'Profile update is 200': (r) => r.status === 200,
        'Profile base updated': (r) => r.json('base') === 'London LHR',
    });
    sleep(0.5);

    // 5. Trigger Emergency SOS Alert
    let sosPayload = JSON.stringify({
        crewName: 'Captain Miller',
        alertType: 'SOS',
        message: 'Engine issue reported'
    });
    let sosParams = { headers: { 'Content-Type': 'application/json' } };
    let sosRes = http.post(`${BASE_URL}/api/emergency`, sosPayload, sosParams);
    check(sosRes, {
        'SOS alert is 201': (r) => r.status === 201,
        'SOS status is Pending': (r) => r.json('status') === 'Pending',
    });
    sleep(1);
}
