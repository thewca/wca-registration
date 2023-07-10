/**
 * This file was auto-generated by openapi-typescript.
 * Do not make direct changes to the file.
 */


export interface paths {
  "/api/v1/registrations/{competition_id}": {
    /** List registrations for a given competition_id */
    get: {
      parameters: {
        path: {
          competition_id: string;
        };
      };
      responses: {
        /** @description Competitions Service is down but we have registrations for the competition_id in our database */
        200: {
          content: {
            "application/json": (components["schemas"]["registration"])[];
          };
        };
        /** @description Competition ID doesnt exist */
        404: never;
        /** @description Competition service unavailable - 500 error */
        500: never;
        /** @description Competition service unavailable - 502 error */
        502: never;
      };
    };
  };
}

export type webhooks = Record<string, never>;

export interface components {
  schemas: {
    registration: {
      user_id: string;
      event_ids: (EventId)[];
    };
    registrationAdmin: {
      user_id: string;
      event_ids: (EventId)[];
      comment?: string;
      admin_comment?: string;
      guests?: number;
    };
    submitRegistrationBody: {
      user_id: string;
      event_ids: (EventId)[];
      comment?: string;
      guests?: number;
    };
    updateRegistrationBody: {
      user_id: string;
      event_ids: (EventId)[];
      comment?: string;
      admin_comment?: string;
      guests?: number;
    };
  };
  responses: never;
  parameters: never;
  requestBodies: never;
  headers: never;
  pathItems: never;
}

export type external = Record<string, never>;

export type operations = Record<string, never>;
