import axios from 'axios';

// If env exists → use it (dev)
// Else → use relative path (production via nginx)
const API_URL = import.meta.env.VITE_API_URL || '/api';

const apiClient = axios.create({
  baseURL: API_URL,
  timeout: 120000, // 2 minutes hard cap to avoid indefinite spinner
  headers: {
    'Content-Type': 'application/json',
  },
});

export const generateHealthcarePlan = async ({
  topic,
  location,
  locationMode = 'manual',
  latitude = null,
  longitude = null
}) => {
  try {
    const response = await apiClient.post('/generate-plan', {
      topic,
      location,
      location_mode: locationMode,
      latitude,
      longitude,
    });
    return response.data;
  } catch (error) {
    if (error.code === 'ECONNABORTED') {
      throw new Error('Request timed out after 2 minutes while generating plan. Please retry.');
    }

    if (error.response) {
      throw new Error(
        error.response.data?.detail || 'Failed to generate healthcare plan'
      );
    } else if (error.request) {
      throw new Error('No response from server. Please ensure backend is running.');
    } else {
      throw new Error(error.message || 'An error occurred');
    }
  }
};

export const generateDocument = async ({ document_type, topic, disease_name = null, hospital_id = 'demo_hospital', patient_id = null }) => {
  try {
    const payload = {
      document_type,
      topic,
      hospital_id,
    };
    if (disease_name) payload.disease_name = disease_name;
    if (patient_id) payload.patient_id = patient_id;

    const response = await apiClient.post('/generate', payload);
    return response.data;
  } catch (error) {
    if (error.response) {
      throw new Error(error.response.data?.detail || 'Failed to generate document');
    }
    throw new Error(error.message || 'Failed to generate document');
  }
};

export const getDocument = async (documentId) => {
  try {
    const response = await apiClient.get(`/document/${documentId}`);
    return response.data;
  } catch (error) {
    if (error.response) {
      throw new Error(error.response.data?.detail || 'Failed to fetch document');
    }
    throw new Error(error.message || 'Failed to fetch document');
  }

};

export default apiClient;
