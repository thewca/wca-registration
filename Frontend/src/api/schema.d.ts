/**
 * This file was auto-generated by openapi-typescript.
 * Do not make direct changes to the file.
 */


export interface paths {
  "/api/v1/users": {
    /** Private: Returns info about a list of users */
    post: {
      requestBody: {
        content: {
          "application/json": components["schemas"]["userIds"];
        };
      };
      responses: {
        /** @description Successfully passed down the Psych Sheet */
        200: {
          content: {
            "application/json": components["schemas"]["userInfo"];
          };
        };
      };
    };
  };
  "/api/v1/registrations/{competition_id}": {
    /** Public: list registrations for a given competition_id */
    get: {
      parameters: {
        path: {
          competition_id: string;
        };
      };
      responses: {
        /** @description  -> PASSING comp service down but registrations exist */
        200: {
          content: {
            "application/json": components["schemas"]["registration"][];
          };
        };
      };
    };
  };
  "/api/v1/registrations/{competition_id}/admin": {
    /** Public: list registrations for a given competition_id */
    get: {
      parameters: {
        path: {
          competition_id: string;
        };
      };
      responses: {
        /** @description  -> PASSING organizer has access to comp 2 */
        200: {
          content: {
            "application/json": components["schemas"]["registrationAdmin"][];
          };
        };
        /** @description  -> PASSING organizer cannot access registrations for comps they arent organizing - multi comp auth */
        401: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
      };
    };
  };
  "/api/v1/register": {
    /** Add an attendee registration */
    post: {
      requestBody: {
        content: {
          "application/json": components["schemas"]["submitRegistrationBody"];
        };
      };
      responses: {
        /** @description -> PASSING competitor submits basic registration */
        202: {
          content: {
            "application/json": components["schemas"]["success_response"];
          };
        };
        /** @description  -> PASSING empty payload provided */
        400: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
        /** @description  -> PASSING user impersonation (no admin permission, JWT token user_id does not match registration user_id) */
        401: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
        /** @description  -> PASSING user cant register while registration is closed */
        403: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
        /** @description  -> PASSING competition does not exist */
        404: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
        /** @description PASSING user registration exceeds guest limit */
        422: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
      };
    };
    /** update or cancel an attendee registration */
    patch: {
      requestBody: {
        content: {
          "application/json": components["schemas"]["updateRegistrationBody"];
        };
      };
      responses: {
        /** @description PASSING user changes comment */
        200: {
          content: {
            "application/json": {
              status?: string;
              registration?: components["schemas"]["registrationAdmin"];
            };
          };
        };
        /** @description PASSING user requests invalid status change to their own reg */
        401: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
        /** @description PASSING user changes events / other stuff past deadline */
        403: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
        /** @description PASSING user does not include required comment */
        422: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
      };
    };
  };
}

export type webhooks = Record<string, never>;

export interface components {
  schemas: {
    error_response: {
      error: number;
    };
    success_response: {
      status: string;
      message: string;
    };
    userIds: components["schemas"]["userId"][];
    userId: number;
    userInfo: {
      id: number;
      name: string;
      wca_id: string;
      gender: string;
      country_iso2: string;
      url: string;
      country: {
        id: string;
        name: string;
        continentId: string;
        iso2: string;
      };
      class: string;
    };
    registration: {
      user_id: string;
      competing: {
        event_ids: EventId[];
      };
    };
    registrationAdmin: {
      user_id: string;
      competing: {
        event_ids: EventId[];
        registered_on: string;
        registration_status: string;
        comment?: string | null;
        admin_comment?: string | null;
      };
      guests?: number | null;
    };
    submitRegistrationBody: {
      user_id: string;
      competition_id: string;
      competing: {
        event_ids?: EventId[];
        comment?: string;
        guests?: number;
      };
    };
    updateRegistrationBody: {
      user_id: string;
      competition_id: string;
      competing?: {
        event_ids?: EventId[];
        status?: string;
        comment?: string;
        admin_comment?: string;
      };
      guests?: number;
    };
  };
  responses: never;
  parameters: never;
  requestBodies: never;
  headers: never;
  pathItems: never;
}

export type $defs = Record<string, never>;

export type external = Record<string, never>;

export type operations = Record<string, never>;
