import sanityClient from '@sanity/client'

export const client = sanityClient({
  projectId: 'qsd9yscz',
  dataset: 'production',
  apiVersion: 'v1',
  token: 'sk5sg55eksKJZSas5ZaLciayeYSiXQmfvpJ7csx5VoO5Lo6aFPMkd0uKPCS9eB3pnVdiFbna468VU38Xp6QX64kWWrfk7Vh7c4SQ2jbbCVYRHlep8kC1g3txMcdYOYSZPZQiCBNx63S91hVSqwMY0vc7eNqxGzMob9l3IcK7MW8zjLAFD3qj',
  useCdn: false,
})