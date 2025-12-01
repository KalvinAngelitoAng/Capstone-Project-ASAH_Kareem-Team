const API_BASE = (import.meta.env.VITE_API_BASE || "http://localhost:3000/api/auth");
import { BASE_URL } from "./config";
import { getAccessToken } from "./auth";

export async function postAuth(endpoint, data) {
  const url = `${API_BASE}${endpoint}`;

  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });

  let payload = {};
  try {
    payload = await res.json();
  } catch (e) {
    
  }

  if (!res.ok) {
    const msg = payload?.message || `Request failed (${res.status})`;
    throw new Error(msg);
  }

  return payload;
}

const ENDPOINTS = {
  //

  // Crew
  CREW_LIST: `${BASE_URL}/crews`,
  CREW_DETAIL: (idCrew) => `${BASE_URL}/crews/${idCrew}`,

  // Equipment
  EQUIPMENT_LIST: `${BASE_URL}/equipments`,
  EQUIPMENT_DETAIL: (idEquipments) => `${BASE_URL}/equipments/${idEquipments}`

  // 



}

export async function getCrewData() {
  const accessToken = getAccessToken();

  const fetchCrew = await fetch(ENDPOINTS.CREW_LIST, {
    headers: { Authorization: `Bearer ${accessToken}`},
  });

  const json = await fetchCrew.json();
  return {
    ...json,
    ok: fetchCrew.ok,
  }
}

export async function deleteCrew(id) {
  try {
    const response = await fetch(`${ENDPOINTS.CREW_DETAIL}/${id}`, {
      method: "DELETE",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: data,
    });
    if (!response.ok) {
      const errorBody = await response.json().catch(() => ({}));
      throw new Error(
        errorBody.message ||
          `Gagal menghapus ID ${id}. Status: ${response.status}`
      );
    }
    return true;
  } catch (error) {
    alert(error.message);
    return false;
  }
}