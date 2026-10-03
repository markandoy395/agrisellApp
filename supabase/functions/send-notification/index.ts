import { JWT } from 'npm:google-auth-library@9.15.1'
import { createClient } from 'jsr:@supabase/supabase-js@2'
import { isWebhookAuthenticated } from './webhook_auth.ts'

type NotificationRecord = {
  notification_id: number
  recipient_auth_user_id: string
  title: string
  description: string
  notification_type?: string
  category?: string
  destination?: string
  order_id?: number | null
  metadata?: Record<string, unknown> | null
}

const firebaseScope = 'https://www.googleapis.com/auth/firebase.messaging'
const channelId = 'agrisell_updates'

Deno.serve(async (request) => {
  if (request.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 })
  }
  if (!isWebhookAuthenticated(request, Deno.env.get('PUSH_WEBHOOK_SECRET'))) {
    return new Response('Unauthorized', { status: 401 })
  }

  const payload = (await request.json()) as { record?: NotificationRecord }
  const notification = payload.record
  if (!notification?.notification_id || !notification.recipient_auth_user_id) {
    return Response.json(
      { error: 'Notification record is required.' },
      { status: 400 },
    )
  }

  const supabase = createClient(requiredSecret('SUPABASE_URL'), serviceRoleKey())
  const { data: devices, error } = await supabase
    .from('notification_devices')
    .select('device_id,fcm_token')
    .eq('user_id', notification.recipient_auth_user_id)
  if (error) throw error

  const accessToken = await firebaseAccessToken()
  let sent = 0
  let removed = 0
  for (const device of devices ?? []) {
    const response = await sendToDevice(accessToken, device.fcm_token, notification)
    if (response.ok) {
      sent++
      continue
    }
    if (await isUnregistered(response)) {
      await supabase
        .from('notification_devices')
        .delete()
        .eq('device_id', device.device_id)
      removed++
    }
  }
  return Response.json({ sent, removed })
})

async function firebaseAccessToken(): Promise<string> {
  const client = new JWT({
    email: requiredSecret('FIREBASE_CLIENT_EMAIL'),
    key: requiredSecret('FIREBASE_PRIVATE_KEY').replace(/\\n/g, '\n'),
    scopes: [firebaseScope],
  })
  const token = await client.authorize()
  if (!token.access_token) {
    throw new Error('Firebase did not return an access token.')
  }
  return token.access_token
}

function sendToDevice(
  accessToken: string,
  token: string,
  notification: NotificationRecord,
) {
  const projectId = requiredSecret('FIREBASE_PROJECT_ID')
  return fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: {
          token,
          notification: {
            title: notification.title,
            body: notification.description,
          },
          data: notificationData(notification),
          android: {
            priority: 'high',
            notification: { channel_id: channelId, sound: 'default' },
          },
        },
      }),
    },
  )
}

function notificationData(notification: NotificationRecord): Record<string, string> {
  const metadata = notification.metadata ?? {}
  const values: Record<string, unknown> = {
    notification_id: notification.notification_id,
    recipient_auth_user_id: notification.recipient_auth_user_id,
    notification_type: notification.notification_type,
    category: notification.category,
    destination: notification.destination,
    order_id: notification.order_id,
    ...metadata,
  }
  return Object.fromEntries(
    Object.entries(values)
      .filter(([, value]) => value !== null && value !== undefined)
      .map(([key, value]) => [key, String(value)]),
  )
}

async function isUnregistered(response: Response): Promise<boolean> {
  if (response.status === 404) return true
  const body = (await response.clone().json().catch(() => null)) as {
    error?: { details?: Array<{ errorCode?: string }> }
  } | null
  return (
    body?.error?.details?.some(
      (detail) => detail.errorCode === 'UNREGISTERED',
    ) ?? false
  )
}

function serviceRoleKey(): string {
  const legacyKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  if (legacyKey) return legacyKey
  const keys = JSON.parse(
    requiredSecret('SUPABASE_SECRET_KEYS'),
  ) as Record<string, string>
  const key = keys.default ?? Object.values(keys).find((value) => value.length > 0)
  if (!key) throw new Error('No Supabase secret key is available.')
  return key
}

function requiredSecret(name: string): string {
  const value = Deno.env.get(name)?.trim()
  if (!value) throw new Error(`${name} is not configured.`)
  return value
}
