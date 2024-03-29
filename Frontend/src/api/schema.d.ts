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
          "application/json": {
            ids: components["schemas"]["userIds"];
          };
        };
      };
      responses: {
        /** @description Successfully returns UserInfo */
        200: {
          content: {
            "application/json": components["schemas"]["userInfo"][];
          };
        };
        /** @description Internal Server Error */
        500: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
      };
    };
  };
  "/api/v1/{competition_id}/payment": {
    /** Public: Gets the Payment Id for the current User and Competition */
    get: {
      parameters: {
        path: {
          competition_id: string;
        };
      };
      responses: {
        /** @description Returns the payment info */
        200: {
          content: {
            "application/json": components["schemas"]["paymentInfo"];
          };
        };
        /** @description Missing Authentication */
        401: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
        /** @description Internal Server Error */
        500: {
          content: {
            "application/json": components["schemas"]["error_response"];
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
        /** @description Lists accepted registrations */
        200: {
          content: {
            "application/json": components["schemas"]["registration"][];
          };
        };
        /** @description Internal Server Error */
        500: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
      };
    };
  };
  "/api/v1/registrations/{competition_id}/waiting": {
    /** Public: Gets the waiting list */
    get: {
      parameters: {
        path: {
          competition_id: string;
        };
      };
      responses: {
        /** @description Lists */
        200: {
          content: {
            "application/json": components["schemas"]["waitingList"];
          };
        };
        /** @description Internal Server Error */
        500: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
      };
    };
  };
  "/api/v1/psych_sheet/{competition_id}/{event_id}": {
    /** Private: Fetches the Psych Sheet for a given competition. The actual computation is handled by other Microservices */
    get: {
      parameters: {
        query?: {
          sort_by?: string;
        };
        path: {
          competition_id: string;
          event_id: EventId;
        };
      };
      responses: {
        /** @description Successfully passed down the Psych Sheet */
        200: {
          content: {
            "application/json": components["schemas"]["psychSheet"];
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
        /** @description Organizer has access to comp */
        200: {
          content: {
            "application/json": components["schemas"]["registrationAdmin"][];
          };
        };
        /** @description Organizer cannot access registrations for comps they arent organizing - multi comp auth */
        401: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
      };
    };
  };
  "/api/v1/register": {
    /** Gets a single registrations */
    get: {
      parameters: {
        query: {
          user_id: number;
          competition_id: string;
        };
      };
      responses: {
        /** @description Returns the Registration */
        200: {
          content: {
            "application/json": components["schemas"]["registrationAdmin"];
          };
        };
        /** @description Missing Authentication */
        401: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
        /** @description Access Denied */
        403: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
        /** @description Internal Server Error */
        500: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
      };
    };
    /** Add an attendee registration */
    post: {
      requestBody: {
        content: {
          "application/json": components["schemas"]["submitRegistrationBody"];
        };
      };
      responses: {
        /** @description Competitor submits basic registration */
        202: {
          content: {
            "application/json": components["schemas"]["success_response"];
          };
        };
        /** @description Empty payload provided */
        400: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
        /** @description User impersonation (no admin permission, JWT token user_id does not match registration user_id) */
        401: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
        /** @description User cant register while registration is closed */
        403: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
        /** @description Competition does not exist */
        404: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
        /** @description User registration exceeds guest limit */
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
        /** @description User changes comment */
        200: {
          content: {
            "application/json": {
              status?: string;
              registration?: components["schemas"]["registrationAdmin"];
            };
          };
        };
        /** @description User requests invalid status change to their own registration */
        401: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
        /** @description User changes events / other stuff past deadline */
        403: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
        /** @description User does not include required comment */
        422: {
          content: {
            "application/json": components["schemas"]["error_response"];
          };
        };
        /** @description Internal Server Error */
        500: {
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
    paymentInfo: {
      id: number;
      status?: string;
    };
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
    waitingListSpot: {
      user_id?: number;
      waiting_list_position?: number;
    };
    waitingList: components["schemas"]["waitingListSpot"][];
    registration: {
      user_id: number;
      competing: {
        event_ids: EventId[];
      };
    };
    sortedRanking: {
      user_id: string;
      wca_id?: string;
      single_rank: number;
      single_best: number;
      average_rank: number;
      average_best: number;
      pos: number;
      tied_previous: boolean;
    };
    psychSheet: {
      sort_by: string;
      sort_by_second?: string;
      sorted_rankings: components["schemas"]["sortedRanking"][];
    };
    registrationAdmin: {
      user_id: number;
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
      user_id: number;
      competition_id: string;
      competing: {
        event_ids?: EventId[];
        comment?: string;
        guests?: number;
      };
    };
    updateRegistrationBody: {
      user_id: number;
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
