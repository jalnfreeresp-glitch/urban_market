// functions/src/index.ts

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

// --- Interfaz para los datos de creación de usuario ---
interface CreateUserData {
  email: string;
  password: string;
  name: string;
  phone: string;
  role: string;
}

// --- Función para crear un nuevo usuario (SOLO ADMIN) ---
export const createUser = functions.https.onCall(async (request) => {
  if (request.auth?.token.admin !== true) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Solo los administradores pueden crear usuarios."
    );
  }

  const data = request.data as CreateUserData;
  const {email, password, name, phone, role} = data;

  try {
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      displayName: name,
    });

    await admin.firestore().collection("users").doc(userRecord.uid).set({
      id: userRecord.uid,
      name: name,
      email: email,
      phone: phone,
      role: role,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isActive: true,
    });

    return {result: `Usuario ${email} creado exitosamente.`};
  } catch (error) {
    console.error("Error creando usuario:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Ocurrió un error al crear el usuario."
    );
  }
});

// --- Interfaz para los datos de estado de usuario ---
interface SetUserStatusData {
    uid: string;
    isActive: boolean;
}

// --- Función para activar/desactivar un usuario (SOLO ADMIN) ---
export const setUserActiveStatus = functions.https.onCall(async (request) => {
  if (request.auth?.token.admin !== true) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Solo los administradores pueden modificar usuarios."
    );
  }

  const data = request.data as SetUserStatusData;
  const {uid, isActive} = data;

  try {
    await admin.auth().updateUser(uid, {disabled: !isActive});

    await admin.firestore().collection("users").doc(uid).update({
      isActive: isActive,
    });

    return {result: `Estado del usuario ${uid} actualizado.`};
  } catch (error) {
    console.error("Error actualizando usuario:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Ocurrió un error al actualizar el usuario."
    );
  }
});

// --- NUEVA FUNCIÓN ---
// --- Interfaz para los datos de actualización de usuario ---
interface UpdateUserData {
  uid: string;
  name: string;
  phone: string;
  role: string;
}

// --- Función para actualizar un usuario (SOLO ADMIN) ---
export const updateUser = functions.https.onCall(async (request) => {
  if (request.auth?.token.admin !== true) {
    throw new functions.https.HttpsError(
      "permission-denied", "Solo los admins pueden actualizar usuarios.");
  }

  const data = request.data as UpdateUserData;
  const {uid, name, phone, role} = data;

  try {
    // Actualiza en Firestore
    await admin.firestore().collection("users").doc(uid).update({
      name: name,
      phone: phone,
      role: role,
    });
    // Actualiza el nombre en Firebase Auth para mantener la consistencia
    await admin.auth().updateUser(uid, {displayName: name});

    return {result: `Usuario ${uid} actualizado.`};
  } catch (error) {
    console.error("Error actualizando usuario:", error);
    throw new functions.https.HttpsError("internal", "Error al actualizar.");
  }
});
// --- FIN DE LA NUEVA FUNCIÓN ---


// --- Interfaz para los datos de rol de admin ---
interface SetAdminRoleData {
    email: string;
}

// --- Función para asignar rol de admin ---
export const setAdminRole = functions.https.onCall(
  async (request) => {
    if (request.auth?.token.admin !== true) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Acción no permitida."
      );
    }

    const data = request.data as SetAdminRoleData;
    const {email} = data;
    try {
      const user = await admin.auth().getUserByEmail(email);
      await admin.auth().setCustomUserClaims(user.uid, {admin: true});
      return {message: `Éxito! ${email} ahora es administrador.`};
    } catch (error) {
      console.error("Error asignando rol de admin:", error);
      throw new functions.https.HttpsError("internal", "Error al asignar rol.");
    }
  });
