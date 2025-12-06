/*
 * Documentation Configuration for TFT Smart Hub Frontend
 * Using JSDoc for JavaScript/Vue documentation
 */

/**
 * @module TFT Smart Hub
 * @description A comprehensive team composition builder and analyzer for Teamfight Tactics
 * @version 1.0.0
 */

// JSDoc Comment Examples:

/**
 * Fetches team compositions from the API
 * @async
 * @function getTeamCompositions
 * @param {Object} filters - Filter parameters
 * @param {string} filters.set - TFT set identifier (e.g., 'TFT15')
 * @param {string} [filters.type] - Team type ('system' or 'user')
 * @param {number} [filters.limit=10] - Maximum results to return
 * @returns {Promise<Array<TeamComp>>} Array of team compositions
 * @throws {Error} When API request fails
 * @example
 * // Get system teams for TFT15
 * const teams = await getTeamCompositions({ 
 *   set: 'TFT15', 
 *   type: 'system' 
 * });
 */

/**
 * CardTile Component
 * @component
 * @description Displays a single champion card with stats and interactions
 * @param {Object} props
 * @param {Champion} props.champion - Champion data object
 * @param {boolean} [props.showStats=true] - Whether to display statistics
 * @param {Function} [props.onSelect] - Callback when card is selected
 * @returns {VNode} Rendered Vue component
 * @example
 * <CardTile 
 *   :champion="championData"
 *   :show-stats="true"
 *   @select="handleCardSelect"
 * />
 */

/**
 * Team Composition Data Model
 * @typedef {Object} TeamComp
 * @property {number} id - Unique identifier
 * @property {string} name - Team composition name
 * @property {string} champions - Comma-separated champion names
 * @property {string} set_identifier - TFT set version
 * @property {string} description - Detailed description
 * @property {number} win_rate - Win rate percentage
 * @property {number} play_rate - Play rate percentage
 * @property {Array<number>} likes - Array of user IDs who liked
 * @property {Date} created_at - Creation timestamp
 * @property {Date} updated_at - Last update timestamp
 */

/**
 * Champion Data Model
 * @typedef {Object} Champion
 * @property {number} id - Unique identifier
 * @property {string} name - Champion name
 * @property {number} tier - Champion tier level (1-5)
 * @property {Array<string>} traits - Champion traits/synergies
 * @property {string} sprite_name - Sprite sheet filename
 * @property {number} sprite_x - X coordinate on sprite sheet
 * @property {number} sprite_y - Y coordinate on sprite sheet
 * @property {string} api_id - External API identifier
 * @property {string} set_identifier - TFT set version
 */

export default {};
