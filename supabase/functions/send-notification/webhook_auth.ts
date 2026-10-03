export function isWebhookAuthenticated(
  request: Request,
  configuredSecret: string | undefined,
): boolean {
  const secret = configuredSecret?.trim()
  return Boolean(secret) &&
    request.headers.get('x-agrisell-webhook-secret') === secret
}
