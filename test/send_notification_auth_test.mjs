import test from 'node:test'
import assert from 'node:assert/strict'
import { isWebhookAuthenticated } from '../supabase/functions/send-notification/webhook_auth.ts'

const request = (secret) => new Request('https://example.com/webhook', {
  method: 'POST',
  headers: secret === undefined ? {} : { 'x-agrisell-webhook-secret': secret },
})

test('missing, empty, or whitespace configuration always denies access', () => {
  for (const configured of [undefined, '', '   ']) {
    for (const supplied of [undefined, '', '   ', 'anything']) {
      assert.equal(isWebhookAuthenticated(request(supplied), configured), false)
    }
  }
})

test('a configured webhook requires the exact server secret', () => {
  assert.equal(isWebhookAuthenticated(request(), 'server-secret'), false)
  assert.equal(isWebhookAuthenticated(request('wrong'), 'server-secret'), false)
  assert.equal(isWebhookAuthenticated(request('server-secret'), 'server-secret'), true)
})
